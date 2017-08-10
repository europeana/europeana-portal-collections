# frozen_string_literal: true

RSpec.feature 'Page titles' do
  describe 'home page' do
    it 'has title "Europeana Collections"' do
      visit home_path(:en)
      expect(page).to have_title('Europeana Collections', exact: true)
    end
  end

  describe 'search page' do
    it 'has title "Query - Search Results - Europeana Collections"' do
      query = 'Beethoven'
      visit search_path(:en, q: query)
      expect(page).to have_title("#{query} - Search Results - Europeana Collections", exact: true)
    end

    it 'has title "Search Results - Europeana Collections"' do
      visit search_path(:en, q: '')
      expect(page).to have_title('Search Results - Europeana Collections', exact: true)
    end
  end

  describe 'collections page' do
    it 'has title "Collection name - Europeana Collections"' do
      visit collection_path(:en, 'music')
      expect(page).to have_title('Music - Europeana Collections', exact: true)
    end
  end

  describe 'galleries page' do
    it 'has title "Galleries - Europeana Collections"' do
      visit galleries_path(:en)
      expect(page).to have_title('Galleries - Europeana Collections', exact: true)
    end
    it 'has title "Gallery name - Galleries - Europeana Collections"' do
      visit gallery_path(:en, 'fashion-dresses')
      expect(page).to have_title('Fashion: dresses - Galleries - Europeana Collections', exact: true)
    end
  end

  describe 'explore page' do
    it 'has title "Explore name - Europeana Collections"' do
      visit explore_newcontent_path(:en)
      expect(page).to have_title('What\'s new? - Europeana Collections', exact: true)
      visit explore_people_path(:en)
      expect(page).to have_title('People - Europeana Collections', exact: true)
    end
  end

  describe 'entity page' do
    it 'has title "Entity Name - Europeana Collections"'
  end

  describe 'events page' do
    let(:json_api_url) { %r{\A#{Rails.application.config.x.europeana[:pro_url]}/json/events(\?|\z)} }
    let(:mime_type) { 'application/vnd.api+json' }

    before do
      stub_request(:get, json_api_url).
        with(headers: { 'Accept' => mime_type, 'Content-Type' => mime_type }).
        to_return(status: 200, body: '', headers: { 'Content-Type' => mime_type })
    end

    it 'has title "Events - Europeana Collections"' do
      visit events_path(:en)
      expect(page).to have_title('Events - Europeana Collections', exact: true)
    end

    it 'has title "Event name - Events - Europeana Collections"'
  end

  describe 'blog page' do
    it 'has title "Blog - Europeana Collections"'
    it 'has title "Blog name - Blog - Europeana Collections"'
  end

  describe 'static page' do
    it 'has title "Page name - Europeana Collections"'
  end
end
