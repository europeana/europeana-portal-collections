RSpec.describe 'redirects for locale handling' do
  context 'no locale indicated' do
    it 'redirects GET / to /en' do
      get('/')
      expect(response).to redirect_to('/en')
    end

    it 'redirects GET /search to /en/search' do
      get('/search')
      expect(response).to redirect_to('/en/search')
    end
  end

  context 'locale indicated in Accept-Language header' do
    let(:headers) { { 'Accept-Language' => 'fr' } }

    it 'redirects GET / to /fr' do
      get('/', {}, headers)
      expect(response).to redirect_to('/fr')
    end

    it 'redirects GET /search to /fr/search' do
      get('/search', {}, headers)
      expect(response).to redirect_to('/fr/search')
    end
  end
end
