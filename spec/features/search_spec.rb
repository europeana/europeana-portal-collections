require 'rails_helper'

RSpec.feature 'Search page', :type => :feature do
  describe 'search page' do
    it 'expects results', js: true do
      visit '/'
      expect(page).to have_css('input[name=q]')
      fill_in('q', with: 'Paris')

      expect(page).to have_css('.searchbar button.search-submit')
      find('.searchbar button.search-submit').trigger('click')
      
      sleep 2
            
      expect(page).to have_css('.results-list ol.result-items li')
    end
    
    it 'expects no results', js: true do
      visit '/'
      expect(page).to have_css('input[name=q]')
      fill_in('q', with: 'XXXPARISXXX')

      expect(page).to have_css('.searchbar button.search-submit')
      find('.searchbar button.search-submit').trigger('click')
      
      sleep 2

      expect(page).to_not have_css('.results-list ol.result-items li')
    end
  end
end
