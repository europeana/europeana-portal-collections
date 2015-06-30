require 'rails_helper'


RSpec.feature 'Object page', :type => :feature do

  describe 'Navigation' do

    it 'expects working previous / next links', js: true   do

      visit '/'
      fill_in('q', with: 'Paris')


      # without the following 'expect' assertion the subsequent 'find' will fail

      expect(page).to have_css('.searchbar button.search-submit')
      find('.searchbar button.search-submit').trigger('click')


      sleep 2

      # without the following 'expect' assertion the subsequent 'find' will fail

      expect(page).to have_css('.results-list ol.result-items li h1 a')
      first('.results-list ol.result-items li h1 a').click


      expect(page).to have_selector('.next')

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

    it 'expects javascript to load large images', js: true  do

      visit '/record/90402/SK_A_2344.html?js=1'

      expect(page).to have_selector('.object-image')
      expect(page).to have_css('.js-img-frame')

    end

  end

end
