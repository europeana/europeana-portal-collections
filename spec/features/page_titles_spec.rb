require 'rails_helper'

RSpec.feature 'Page titles' do

  describe 'home page' do
    it 'has title "Europeana Collections"' do
      visit '/en'
      expect(page).to have_title('Europeana Collections', exact: true)
    end
  end

  describe 'search page' do
    it 'has title "Query - Search Results - Europeana Collections"' do
      query = 'Beethoven'
      visit "/en/search?q=#{query}"
      expect(page).to have_title("#{query} - Search Results - Europeana Collections", exact: true)
    end

    it 'has title "Search Results - Europeana Collections"' do
      visit '/en/search?q='
      expect(page).to have_title('Search Results - Europeana Collections', exact: true)
    end
  end

  describe 'collections page' do
    it 'has title "Music - Europeana Collections"' do
      visit '/en/collections/music'
      expect(page).to have_title('Music - Europeana Collections', exact: true)
    end
  end

  describe 'galleries page' do
    it 'has title "Fashion: dresses - Galleries - Europeana Collections"' do
      visit '/en/explore/galleries/fashion-dresses'
      expect(page).to have_title('Fashion: dresses - Galleries - Europeana Collections', exact: true)
    end
  end

  describe 'explore page' do
    it 'has title "What\'s new? - Europeana Collections"' do
      visit '/en/explore/newcontent'
      expect(page).to have_title('What\'s new? - Europeana Collections', exact: true)
    end
    it 'has title "People - Europeana Collections"' do
      visit '/en/explore/people'
      expect(page).to have_title('People - Europeana Collections', exact: true)
    end
  end
end
