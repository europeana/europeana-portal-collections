require 'rails_helper'

RSpec.feature 'Search page' do
  [false, true].each do |js|
    context (js ? 'with JS' : 'without JS'), js: js do
      describe 'search page' do
        it 'expects results' do
          visit '/en'

          sleep 3 if js

          expect(page).to have_css('input[name=q]')

          fill_in('q', with: 'paris')

          click_button('Search')

          sleep 2 if js

          expect(page.all('.results-list').size).to be > (0)

          expect(page.all('.results-list ol.result-items li').size).to be_between(1, 24)
        end

        it 'permits empty searches' do
          visit '/en'

          sleep 3 if js

          fill_in('q', with: '')

          click_button('Search')

          sleep 2 if js

          expect(current_path).to eq('/en/search')
        end

        it 'ignores 2nd empty search' do
          visit '/en'

          sleep 3 if js

          fill_in('q', with: 'paris')

          click_button('Search')

          sleep 2 if js

          fill_in('qf[]', with: '')

          click_button('Search')

          sleep 2 if js

          expect(page.all('li.search-tag').size).to eq(1)
        end

        it 'does not submit placeholder text' do
          visit '/en'

          sleep 3 if js

          fill_in('q', with: '')

          click_button('Search')

          sleep 2 if js

          placeholder = find('.searchbar input.search-input')[:placeholder]

          expect(page.all('li.search-tag', text: placeholder)).to be_blank
        end
      end
    end
  end
end
