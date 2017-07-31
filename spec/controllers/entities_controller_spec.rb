# frozen_string_literal: true
RSpec.describe EntitiesController do
  describe 'concerns' do
    subject { described_class }
    it { is_expected.to include(Europeana::EntitiesApiConsumer) }
  end

  describe 'GET #suggest' do
    before do
      stub_request(:get, Europeana::API.url + '/entities/suggest').
        with(query: hash_including(scope: 'europeana')).
        to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/ld+json' })
    end

    it 'returns http success' do
      get :suggest, locale: 'en'
      expect(response).to have_http_status(:success)
    end

    it 'queries the entity API' do
      get :suggest, locale: 'en', text: 'van'

      expect(
        a_request(:get, Europeana::API.url + '/entities/suggest').
        with(query: hash_including(text: 'van', scope: 'europeana'))
      ).to have_been_made.once
    end
  end

  describe 'GET #show' do
    before do
      Rails.application.config.x.europeana[:entities_api_key] = 'apikey'
      stub_request(:get, Europeana::API.url + '/entities/agent/base/1234?wskey=apikey').
        to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/ld+json' })
    end

    context 'when entity feature flag is disabled' do
      before do
        Rails.application.config.x.enable.entity_page = false
      end

      it 'returns http 404 not found' do
        get :show, locale: 'en', type: 'agent', namespace: 'base', identifier: '1234'

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when entity feature flag is enabled' do
      before do
        Rails.application.config.x.enable.entity_page = true
      end

      it 'returns http success' do
        get :show, locale: 'en', type: 'agent', namespace: 'base', identifier: '1234'

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe '#body_cache_key' do
    before do
      subject.params[:type] = 'agent'
      subject.params[:namespace] = 'base'
      subject.params[:identifier] = '123456'
    end
    it 'should return the body cache key' do
      expect(subject.send(:body_cache_key)).to eq('entities/agent/base/123456')
    end
  end
end
