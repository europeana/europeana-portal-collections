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

  describe 'GET #fetch' do
    before do
      stub_request(:get, Europeana::API.url + '/entities/agent/base/1234?wskey=' + Rails.application.config.x.europeana[:entities_api_key]).
        to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/ld+json' })
    end

    it 'returns http success' do
      get :show, locale: 'en', type: 'agent', namespace: 'base', identifier: '1234'

      expect(response).to have_http_status(:success)
    end
  end
end
