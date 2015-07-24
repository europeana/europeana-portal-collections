RSpec.feature 'Object page', :type => :feature do
  describe 'Navigation' do
    it 'expects working previous / next links', js: true do
      visit '/'

      sleep 3

      fill_in('q', with: 'paris')

      expect(page).to have_css('.searchbar button.search-submit')

      find('.searchbar button.search-submit').click

      sleep 3

      find('.results-list ol.result-items li:first-child h1 a').click

      sleep 3

      expect(page).to have_selector('.next')

      page_title_1 = page.title

      find('.next a').click

      sleep 3

      page_title_2 = page.title

      expect(page).to have_css('.next a')
      expect(page).to have_css('.previous a')

      expect(page_title_1).not_to eq(page_title_2)

      find('.previous a').click

      sleep 3

      expect(page.title).to eq(page_title_1)
    end
  end
end
