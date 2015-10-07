RSpec.describe BrowseController do
  describe 'GET new_content' do
    before do
      get :new_content
      Rails.cache.write('browse/new_content/providers', providers)
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
