require 'rails_helper'

RSpec.feature 'Page titles' do

  before do
    visit '/en'
  end

  describe 'home page' do
    it 'has title "Europeana Collections"' do
      expect(page).to have_title('Europeana Collections')
    end
  end

  describe 'collections page' do
    it 'has title "Search Results - Europeana Collections"' do
      # fill_in('.search-input', with: '')
      # click_link('.search-submit')
    end

    it 'has title "Query - Search Results - Europeana Collections"' do
      # fill_in('.search-input', with: 'Beethoven')
      # click('.search-submit')
    end
  end
end
