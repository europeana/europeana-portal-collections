# frozen_string_literal: true
RSpec.describe BlogPostsController do
  JSON_API_URL = %r{\A#{Rails.application.config.x.europeana[:pro_url]}/json/blogposts(\?|\z)}
  JSON_API_CONTENT_TYPE = 'application/vnd.api+json'

  before do
    stub_request(:get, JSON_API_URL).
      with(headers: {
             'Accept' => JSON_API_CONTENT_TYPE,
             'Content-Type' => JSON_API_CONTENT_TYPE
           }).
      to_return(
        status: 200,
        body: '{"meta": {"count": 0, "total": 0}, "data":[]}',
        headers: { 'Content-Type' => JSON_API_CONTENT_TYPE }
      )
  end

  describe 'GET #index' do
    it 'queries the Pro JSON-API for 6 posts' do
      get :index, locale: 'en'
      expect(
        a_request(:get, JSON_API_URL)
      ).to have_been_made.once
    end

    it 'requests 6 blog posts' do
      get :index, locale: 'en'
      expect(
        a_request(:get, JSON_API_URL).
        with(query: hash_including(page: { number: '1', size: '6' }))
      ).to have_been_made.once
      expect(assigns(:pagination_per)).to eq(6)
      expect(assigns(:pagination_page)).to eq(1)
    end

    it 'requests the page in `page` param' do
      get :index, locale: 'en', page: 3
      expect(
        a_request(:get, JSON_API_URL).
        with(query: hash_including(page: { number: '3', size: '6' }))
      ).to have_been_made.once
      expect(assigns(:pagination_per)).to eq(6)
      expect(assigns(:pagination_page)).to eq(3)
    end

    it 'includes related resources' do
      get :index, locale: 'en'
      expect(
        a_request(:get, JSON_API_URL).
        with(query: hash_including(include: 'network'))
      ).to have_been_made.once
    end

    it 'returns http success' do
      get :index, locale: 'en'
      expect(response).to have_http_status(:success)
    end

    it 'assigns result set to @blog_posts' do
      get :index, locale: 'en'
      expect(assigns(:blog_posts)).to be_a(JsonApiClient::ResultSet)
    end

    it 'defaults to HTML format' do
      get :index, locale: 'en'
      expect(response.content_type).to eq('text/html')
    end

    it 'does not respond to .json format' # or should it, just outputting the JSON-API response?
  end
end
