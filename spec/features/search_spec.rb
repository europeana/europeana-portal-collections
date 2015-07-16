require 'rails_helper'

RSpec.feature 'Search page', :type => :feature do
  describe 'search page' do
    it 'expects results', js: true do
      visit '/'

      sleep 3

      expect(page).to have_css('input[name=q]')

      page.execute_script '$("input[name=q]").val("paris")'

      expect(page).to have_css('.searchbar button.search-submit')

      page.execute_script '$(".searchbar button.search-submit").trigger("click")'

      sleep 2

      list_present = page.evaluate_script '$(".results-list").length > 0'
      expect(list_present).to be true

      item_count = page.evaluate_script '$(".results-list ol.result-items li").length'
      expect(item_count).to be_between(1, 24)
    end

    it 'permits empty searches' do
      visit '/'

      fill_in('q', with: '')
      find('button.search-submit').click

      expect(current_path).to eq('/search')
    end

    it 'ignores 2nd empty search' do
      visit '/'

      fill_in('q', with: 'paris')
      find('button.search-submit').click

      find('button.search-submit').click

      expect(page.all('li.search-tag').size).to eq(1)
    end

    it 'does not submit placeholder text' do
      visit '/'

      fill_in('q', with: '')
      find('button.search-submit').click

      placeholder = find('.searchbar input.search-input')[:placeholder]

      expect(page.all('li.search-tag', text: placeholder)).to be_blank
    end
  end
end
