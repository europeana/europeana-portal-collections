RSpec.feature 'Object page', :type => :feature do
  describe 'Navigation' do
    it 'expects working previous / next links', js: true do
      visit '/'
      fill_in('q', with: 'Paris')

      # without the following 'expect' assertion the subsequent 'find' will fail

      expect(page).to have_css('.searchbar button.search-submit')
      page.execute_script '$(".searchbar button.search-submit").trigger("click");'
      sleep 2

      # without the following 'expect' assertion the subsequent 'find' will fail
      expect(page).to have_css('.results-list ol.result-items li h1 a')

      page.execute_script '$(".results-list ol.result-items li:first h1 a").trigger("click");'
      sleep 2

      expect(page).to have_selector('.next')
      page_title = page.title

      find('.next a').click
      sleep 2

      expect(page).to have_css('.next a')
      expect(page).to have_css('.previous a')

      assert page.title != page_title

      find('.previous a').click
      assert page.title == page_title
    end
  end
end
