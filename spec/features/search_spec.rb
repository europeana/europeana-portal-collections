require 'rails_helper'

RSpec.feature 'Search page', :type => :feature do
  describe 'search page' do
    it 'expects results', js: true do
      visit '/'

      sleep 3

      expect(page).to have_css('input[name=q]')
      fill_in('q', with: 'paris')
      expect(page).to have_css('.searchbar button.search-submit')
      find('.searchbar button.search-submit').click

      sleep 2

      expect(page.all('.results-list').size).to be > (0)

      expect(page.all('.results-list ol.result-items li').size).to be_between(1, 24)
    end

    it 'permits empty searches' do
      visit '/'

      fill_in('q', with: '')
      find('button.search-submit').click

      path_root = ENV['RAILS_RELATIVE_URL_ROOT'] || ''
      expect(current_path).to eq(path_root + '/search')
    end

    it 'ignores 2nd empty search' do
      visit '/'

      fill_in('q', with: 'paris')
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
