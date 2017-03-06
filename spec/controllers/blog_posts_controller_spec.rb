# frozen_string_literal: true
RSpec.describe BlogPostsController do
  before do
    stub_request(:get, %r{\Ahttp://pro\.europeana\.eu/json/blogposts(\?|\z)}).
      with(headers: {
             'Accept' => 'application/vnd.api+json',
             'Content-Type' => 'application/vnd.api+json'
           }).
      to_return(
        status: 200,
        body: '{"meta": {"count": 0, "total": 0}, "data":[]}',
        headers: { 'Content-Type' => 'application/vnd.api+json' }
      )
  end

  describe 'GET #index' do
    it 'queries the Pro JSON-API for 6 posts' do
      get :index, locale: 'en'
      expect(
        a_request(:get, 'http://pro.europeana.eu/json/blogposts').
        with(query: hash_including(page: { number: '1', size: '6' }))
      ).to have_been_made.once
    end

    it 'requests the page in `page` param' do
      get :index, locale: 'en', page: 3
      expect(
        a_request(:get, 'http://pro.europeana.eu/json/blogposts').
        with(query: hash_including(page: { number: '3', size: '6' }))
      ).to have_been_made.once
    end

    it 'includes related resources'

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
