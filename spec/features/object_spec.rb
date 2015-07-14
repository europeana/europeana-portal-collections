RSpec.feature 'Object page', :type => :feature do
  describe 'Navigation' do
    it 'expects working previous / next links', js: true do
      visit '/'

      sleep 3

      page.execute_script '$("input[name=q]").val("paris")'

      expect(page).to have_css('.searchbar button.search-submit')
      page.execute_script '$(".searchbar button.search-submit").trigger("click")'

      sleep 3

      # without the following 'expect' assertion the subsequent 'find' will fail
      expect(page).to have_css('.results-list ol.result-items li h1 a')

      page.execute_script '$(".results-list ol.result-items li:first h1 a").trigger("click")'

      sleep 3

      expect(page).to have_selector('.next')

      page_title_1 = page.title

      page.execute_script '$(".next a").trigger("click")'

      sleep 3

      page_title_2 = page.title

      expect(page).to have_css('.next a')
      expect(page).to have_css('.previous a')

      assert page_title_1 != page_title_2

      page.execute_script '$(".previous a").trigger("click")'

      sleep 3

      assert page.title == page_title_1
    end
  end
end