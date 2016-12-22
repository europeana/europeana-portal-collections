# frozen_string_literal: true
RSpec.describe EntitiesController do
  describe 'GET #suggest' do
    before do
      stub_request(:get, Europeana::API.url + '/entities/suggest').
        with(query: hash_including(scope: 'europeana')).
        to_return(status: 200, body: '{}', headers: {'Content-Type' => 'application/ld+json'})
    end

    it 'returns http success' do
      get :suggest, { locale: 'en' }
      expect(response).to have_http_status(:success)
    end

    it 'queries the entity API' do
      get :suggest, { locale: 'en', text: 'van' }

      expect(
          a_request(:get, Europeana::API.url + '/entities/suggest').
          with(query: hash_including(text: 'van', scope: 'europeana'))
      ).to have_been_made.once
    end
  end
end
