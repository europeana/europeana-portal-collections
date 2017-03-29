# frozen_string_literal: true
RSpec.describe EventsController do
  let(:json_api_url) { %r{\A#{Rails.application.config.x.europeana[:pro_url]}/json/events(\?|\z)} }
  let(:json_api_content_type) { 'application/vnd.api+json' }
  let(:response_body) { '{"meta": {"count": 1, "total": 1}, "data": [{ "id": "1", "type": "events" }]}' }

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
    it { is_expected.to include(PaginatedController) }
  end

  describe 'GET #index' do
    it 'queries the Pro JSON-API for 6 posts' do
      get :index, locale: 'en'
      expect(
        a_request(:get, json_api_url)
      ).to have_been_made.once
    end

    it 'requests 6 event posts' do
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
        with(query: hash_including(include: 'locations,network'))
      ).to have_been_made.once
    end

    it 'returns http success' do
      get :index, locale: 'en'
      expect(response).to have_http_status(:success)
    end

    it 'assigns result set to @events' do
      get :index, locale: 'en'
      expect(assigns(:events)).to be_a(JsonApiClient::ResultSet)
    end

    it 'defaults to HTML format' do
      get :index, locale: 'en'
      expect(response.content_type).to eq('text/html')
    end

    it 'does not respond to .json format' # or should it, just outputting the JSON-API response?
  end

  describe 'GET #show' do
    it 'queries the Pro JSON-API for the post' do
      get :show, locale: 'en', slug: 'conference'
      expect(
        a_request(:get, json_api_url).
        with(query: hash_including(filter: { slug: 'conference' }, page: { number: '1', size: '1' }))
      ).to have_been_made.once
    end

    it 'includes related resources' do
      get :show, locale: 'en', slug: 'conference'
      expect(
        a_request(:get, json_api_url).
        with(query: hash_including(include: 'locations,network'))
      ).to have_been_made.once
    end

    context 'when event is found' do
      it 'returns http success' do
        get :show, locale: 'en', slug: 'conference'
        expect(response).to have_http_status(:success)
      end
    end

    context 'when event is not found' do
      let(:response_body) { '{"meta": {"count": 0, "total": 0}, "data":[]}' }
      it 'returns http 404' do
        get :show, locale: 'en', slug: 'conference'
        expect(response).to have_http_status(404)
      end
    end

    it 'defaults to HTML format' do
      get :show, locale: 'en', slug: 'conference'
      expect(response.content_type).to eq('text/html')
    end
  end
end
