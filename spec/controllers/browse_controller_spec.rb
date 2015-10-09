RSpec.describe BrowseController do
  describe 'GET colours' do
    before(:each) do
      get :colours
    end

    it 'should render the colour browse Mustache template' do
      expect(response.status).to eq(200)
      expect(response).to render_template('browse/colours')
    end

    it 'should get colours from the API' do
      expect(an_api_search_request).to have_been_made
    end

    it 'should assign colours from COLOURPALETTE facet' do
      expect(assigns[:colours]).to be_a(Array)
    end
  end

  describe 'GET new_content' do
    before(:each) do
      Rails.cache.write('browse/new_content/providers', providers)
      get :new_content
    end

    let(:providers) do
      [
        { text: 'A Provider' },
        { text: 'Another Provider' },
        { text: 'A Different Provider' }
      ]
    end

    it 'should render the new content Mustache template' do
      expect(response.status).to eq(200)
      expect(response).to render_template('browse/new_content')
    end

    it 'should assign providers from cache' do
      expect(assigns[:providers]).to eq(providers)
    end
  end
end
