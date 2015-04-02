require 'rails_helper'

RSpec.feature 'Object page', :type => :feature do
  describe 'object page' do
  
    it 'expects working previous link', :js => true do
      
      current_window.maximize
      visit '/'
      fill_in('q', with: 'Paris')
      find('.searchbar button.search-submit').click
      
      first('.results-list ol.result-items li h1 a').click
      
      expect(page).to have_css('.next a')
      
      page_title = page.title

      # next 
            
      find('.next a').click

      expect(page).to have_css('.next a')
      expect(page).to have_css('.previous a')

      assert page.title != page_title

      # prev 
            
      find('.previous a').click
      assert page.title == page_title
      
    end
    
  end

end
