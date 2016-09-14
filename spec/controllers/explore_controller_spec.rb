RSpec.shared_examples 'collection aware' do
  context 'when theme param is present' do
    let(:params) { { locale: 'en', format: 'html', theme: collections(:music).key } }

    it 'should load collection' do
      expect(assigns[:collection]).to eq(collections(:music))
    end
  end
end

RSpec.describe ExploreController do
  describe 'GET colours' do
    before(:each) do
      Rails.cache.write('explore/colours/facets', [])
      get :colours, params
    end

    let(:params) { { locale: 'en', format: 'html' } }

    it_behaves_like 'collection aware'

    it 'should render the colour explore Mustache template' do
      expect(response.status).to eq(200)
      expect(response).to render_template('explore/colours')
    end

    it 'should not get colours from the API' do
      expect(an_api_search_request).not_to have_been_made
    end

    it 'should assign colours from COLOURPALETTE facet' do
      expect(assigns[:colours]).to be_a(Array)
    end
  end

  describe 'GET new_content' do
    before(:each) do
      Rails.cache.write('browse/new_content/providers', providers)
      get :new_content, params
    end

    let(:params) { { locale: 'en', format: 'html' } }
    let(:providers) do
      [
        { text: 'A Provider' },
        { text: 'Another Provider' },
        { text: 'A Different Provider' }
      ]
    end

    it 'should render the new content Mustache template' do
      expect(response.status).to eq(200)
      expect(response).to render_template('explore/new_content')
    end

    it 'should assign providers from cache' do
      expect(assigns[:providers]).to eq(providers)
    end

    it_behaves_like 'collection aware'
  end

  describe 'GET sources' do
    before(:each) do
      Rails.cache.write('browse/sources/providers', providers)
      get :sources, params
    end

    let(:params) { { locale: 'en', format: 'html' } }
    let(:providers) do
      [
        { text: 'A Provider', count: 5000 },
        { text: 'Another Provider', count: 3000 },
        { text: 'A Different Provider', count: 1000 }
      ]
    end

    it 'should render the sources Mustache template' do
      expect(response.status).to eq(200)
      expect(response).to render_template('explore/sources')
    end

    it 'should not get providers from the API' do
      expect(an_api_search_request).not_to have_been_made
    end

    it 'should assign providers from cache' do
      expect(assigns[:providers].size).to eq(providers.size)
    end

    it 'should add URLs to providers' do
      expect(assigns[:providers].all? { |p| p.key?(:url) }).to be(true)
    end

    it 'should add data providers to providers' do
      expect(assigns[:providers].all? { |p| p[:data_providers].is_a?(Array) }).to be(true)
    end

    it_behaves_like 'collection aware'
  end

  describe 'GET people' do
    before(:each) do
      get :people, params
    end

    let(:params) { { locale: 'en', format: 'html' } }

    it 'should render the Mustache template' do
      expect(response.status).to eq(200)
      expect(response).to render_template('explore/people')
    end

    it 'should assign explore entries from db' do
      expect(assigns[:people].sort).to eq(BrowseEntry.person.sort)
    end

    it_behaves_like 'collection aware'
  end

  describe 'GET topics' do
    before(:each) do
      get :topics, params
    end

    let(:params) { { locale: 'en', format: 'html' } }

    it 'should render the Mustache template' do
      expect(response.status).to eq(200)
      expect(response).to render_template('explore/topics')
    end

    it 'should assign explore entries from db' do
      expect(assigns[:topics].sort).to eq(BrowseEntry.topic.sort)
    end

    it_behaves_like 'collection aware'
  end

  describe 'GET periods' do
    before(:each) do
      get :periods, params
    end

    let(:params) { { locale: 'en', format: 'html' } }

    it 'should render the Mustache template' do
      expect(response.status).to eq(200)
      expect(response).to render_template('explore/periods')
    end

    it 'should assign explore entries from db' do
      expect(assigns[:periods].sort).to eq(BrowseEntry.period.sort)
    end

    it_behaves_like 'collection aware'
  end
end
