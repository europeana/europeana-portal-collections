require 'rails_helper'

RSpec.feature 'Search page', :type => :feature do
  describe 'search page' do
    it 'expects results', :js => true do
      current_window.maximize
      visit '/'
      expect(page).to have_css('input[name=q]')
      fill_in('q', with: 'Paris')
      find('.searchbar button.search-submit').click
      expect(page).to have_css('.results-list ol.result-items li')
    end
    
    it 'expects no results', :js => true do
      current_window.maximize
      visit '/'
      expect(page).to have_css('input[name=q]')
      fill_in('q', with: 'XXXPARISXXX')
      find('.searchbar button.search-submit').click
      expect(page).to_not have_css('.results-list ol.result-items li')
    end
  end
end
