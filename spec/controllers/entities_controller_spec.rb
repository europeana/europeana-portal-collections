# frozen_string_literal: true

RSpec.describe EntitiesController do
  let(:entities_api_key) { 'apikey' }

  before do
    Rails.application.config.x.europeana[:entities].api_key = entities_api_key
  end

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

    context 'when language param is present' do
      it 'is sent to the entity API' do
        get :suggest, locale: 'en', text: 'van', language: 'en,de'

        expect(
          a_request(:get, Europeana::API.url + '/entities/suggest').
          with(query: hash_including(text: 'van', scope: 'europeana', language: 'en,de'))
        ).to have_been_made.once
      end
    end
  end

  describe 'GET #show' do
    before do
      stub_request(:get, Europeana::API.url + '/entities/agent/base/1234').
        with(query: hash_including(wskey: entities_api_key)).
        to_return(status: 200, body: api_responses(:entities_fetch), headers: { 'Content-Type' => 'application/ld+json' })
    end

    context 'when entity feature flag is disabled' do
      before do
        Rails.application.config.x.enable.entity_page = false
      end

      it 'returns http 404 not found' do
        get :show, locale: 'en', type: 'people', id: '1234'

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when entity feature flag is enabled' do
      before do
        Rails.application.config.x.enable.entity_page = true
      end

      context 'without slug in URL' do
        it 'redirects to URL with slug' do
          get :show, locale: 'en', type: 'people', id: '1234'

          expect(response).to redirect_to('/en/explore/people/1234-david-hume')
        end
      end

      context 'with wrong slug in URL' do
        it 'redirects to URL with slug' do
          get :show, locale: 'en', type: 'people', id: '1234', slug: 'david'

          expect(response).to redirect_to('/en/explore/people/1234-david-hume')
        end
      end

      context 'with slug in URL' do
        let(:params) { { locale: 'en', type: 'people', id: '1234', slug: 'david-hume' } }

        it 'returns http success' do
          get :show, params

          expect(response).to have_http_status(:success)
        end

        it 'queries the entity API' do
          get :show, params

          expect(
            a_request(:get, Europeana::API.url + '/entities/agent/base/1234').
            with(query: hash_including(wskey: entities_api_key))
          ).to have_been_made.once
        end
      end
    end
  end

  describe '#body_cache_key' do
    before do
      subject.params[:type] = 'people'
      subject.params[:id] = '123456'
    end

    it 'should return the body cache key' do
      expect(subject.send(:body_cache_key)).to eq('entities/people/123456')
    end
  end
end
