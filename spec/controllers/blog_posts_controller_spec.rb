# frozen_string_literal: true
RSpec.describe BlogPostsController do
  let(:json_api_url) { %r{\A#{Rails.application.config.x.europeana[:pro_url]}/json/blogposts(\?|\z)} }
  let(:json_api_content_type) { 'application/vnd.api+json' }
  let(:response_body) { '{"meta": {"count": 0, "total": 0}, "data": [ { "id": 1, "type": "blogposts" } ]}' }

  before do
    stub_request(:get, json_api_url).
      with(headers: {
             'Accept' => json_api_content_type,
             'Content-Type' => json_api_content_type
           }).
      to_return(
        status: 200,
        body: response_body,
        headers: { 'Content-Type' => json_api_content_type }
      )
  end

  describe 'concerns' do
    subject { described_class }
    it { is_expected.to include(HomepageHeroImage) }
    it { is_expected.to include(PaginatedController) }
  end

  describe 'GET #index' do
    it 'queries the Pro JSON-API' do
      get :index, locale: 'en'
      expect(
        a_request(:get, json_api_url)
      ).to have_been_made.once
    end

    it 'sorts by -datepublish' do
      get :index, locale: 'en'
      expect(
        a_request(:get, json_api_url).
        with(query: hash_including(sort: '-datepublish'))
      ).to have_been_made.once
    end

    it 'requests 6 blog posts' do
      get :index, locale: 'en'
      expect(
        a_request(:get, json_api_url).
        with(query: hash_including(page: { number: '1', size: '6' }))
      ).to have_been_made.once
      expect(controller.pagination_per).to eq(6)
      expect(controller.pagination_page).to eq(1)
    end

    it 'requests the page in `page` param' do
      get :index, locale: 'en', page: 3
      expect(
        a_request(:get, json_api_url).
        with(query: hash_including(page: { number: '3', size: '6' }))
      ).to have_been_made.once
      expect(controller.pagination_per).to eq(6)
      expect(controller.pagination_page).to eq(3)
    end

    it 'includes related resources' do
      get :index, locale: 'en'
      expect(
        a_request(:get, json_api_url).
        with(query: hash_including(include: 'persons'))
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

    it 'responds to .rss format' do
      get :index, locale: 'en', format: 'rss'
      expect(response).to have_http_status(:success)
    end

    it 'does not respond to .json format' # or should it, just outputting the JSON-API response?
  end

  describe 'GET #show' do
    it 'queries the Pro JSON-API for the post' do
      get :show, locale: 'en', slug: 'important-news'
      expect(
        a_request(:get, json_api_url).
        with(query: hash_including(filter: { slug: 'important-news' }, page: { number: '1', size: '1' }))
      ).to have_been_made.once
    end

    it 'includes related resources' do
      get :show, locale: 'en', slug: 'important-news'
      expect(
        a_request(:get, json_api_url).
        with(query: hash_including(include: 'network'))
      ).to have_been_made.once
    end

    context 'when post is found' do
      it 'returns http success' do
        get :show, locale: 'en', slug: 'important-news'
        expect(response).to have_http_status(:success)
      end
    end

    context 'when post is not found' do
      let(:response_body) { '{"meta": {"count": 0, "total": 0}, "data":[]}' }
      it 'returns http 404' do
        get :show, locale: 'en', slug: 'important-news'
        expect(response).to have_http_status(404)
      end
    end

    it 'defaults to HTML format' do
      get :show, locale: 'en', slug: 'important-news'
      expect(response.content_type).to eq('text/html')
    end
  end

  describe '#pro_json_api_theme_filters_from_collections' do
    let(:whitelisted_keys) { %w(fashion world-war-I) }
    subject { described_class.new.send(:pro_json_api_theme_filters_from_collections) }

    it 'includes whitelisted collections' do
      expect(subject.count).to eq(whitelisted_keys.size)
      Collection.where(key: whitelisted_keys).each do |collection|
        key = collection.key.downcase
        expect(subject).to have_key(key.to_sym)
        expect(subject[key.to_sym]).to eq(filter: "culturelover-#{key}", label: collection.landing_page.title)
      end
    end
  end
end
