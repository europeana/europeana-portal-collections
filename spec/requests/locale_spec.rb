# frozen_string_literal: true

RSpec.describe 'redirects for locale handling' do
  context 'without locale in URL' do
    it 'redirects GET / to /en' do
      get('/')
      expect(response).to redirect_to('/en')
    end

    it 'redirects GET /search to /en/search' do
      get('/search')
      expect(response).to redirect_to('/en/search')
    end

    context 'with locale indicated in Accept-Language header' do
      context 'when supported' do
        let(:headers) { { 'Accept-Language' => 'fr' } }

        it 'redirects GET / to /:locale' do
          get('/', {}, headers)
          expect(response).to redirect_to('/fr')
        end

        it 'redirects GET /search to /:locale/search' do
          get('/search', {}, headers)
          expect(response).to redirect_to('/fr/search')
        end
      end

      context 'when not supported' do
        let(:headers) { { 'Accept-Language' => 'ja' } }

        it 'redirects GET / to /en' do
          get('/', {}, headers)
          expect(response).to redirect_to('/en')
        end

        it 'redirects GET /search to /en/search' do
          get('/search', {}, headers)
          expect(response).to redirect_to('/en/search')
        end
      end
    end
  end

  context 'with invalid locale in URL' do
    it 'responds with 404' do
      get('/ja')
      expect(response).to have_http_status(:not_found)
    end
  end
end
