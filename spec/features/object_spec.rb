# frozen_string_literal: true

RSpec.feature 'Object page', :annotations_api do
  describe 'navigation' do
    context 'with JS', js: true do
      # No HTML next/previous links when action caching is in use
      # @todo Make this spec detect the AJAX-added links
      #       it 'expects working previous / next links' do
      #         visit '/en'

      #         sleep 3

      #         fill_in('q', with: 'paris')

      #         click_button('Search')

      #         sleep 3

      #         find('.results-list ol.result-items li:first-child h1 a').click

      #         sleep 3

      #         expect(page).to have_css('.next')

      #         page_title_1 = page.title

      #         find('.next a').click

      #         sleep 3

      #         page_title_2 = page.title

      #         expect(page).to have_css('.next a')
      #         expect(page).to have_css('.previous a')

      #         expect(page_title_1).not_to eq(page_title_2)

      #         find('.previous a').click

      #         sleep 3

      #         expect(page.title).to eq(page_title_1)
      #       end
    end

    context 'without JS', js: false do
      it 'expects no working previous / next links' do
        visit '/en'

        fill_in('q', with: 'paris')

        click_button('Search')

        page.all('.results-list ol.result-items li h2 a')[2].click

        expect(page).not_to have_css('.next')
        expect(page).not_to have_css('.previous')
      end
    end
  end

  describe 'feedback form' do
    [false, true].each do |js|
      context (js ? 'with JS' : 'without JS'), js: js do
        context 'with recipient configured' do
          before do
            Europeana::FeedbackButton.mail_to = 'feedback@example.com'
          end
          it 'is present' do
            visit '/en/record/abc/123'
            sleep 1 if js
            expect(page).to have_css('#feedback-form')
          end
        end

        context 'without recipient configured' do
          before do
            Europeana::FeedbackButton.mail_to = nil
          end
          it 'is not present' do
            visit '/en/record/abc/123'
            sleep 1 if js
            expect(page).to_not have_css('#feedback-form')
          end
        end
      end
    end
  end

  describe 'search form' do
    [false, true].each do |js|
      context (js ? 'with JS' : 'without JS'), js: js do
        it 'has a working search form' do
          visit '/en/record/abc/123'
          sleep 1 if js
          begin
            page.find(:xpath, '//a[@class="cc_btn cc_btn_accept_all"]').click if js
          rescue Capybara::ElementNotFound
            # The above click statement fails on Travis as the disclaimer isn't present
          end
          fill_in('q', with: 'paris')
          click_button('Search')
          expect(current_path).to eq('/en/search')
        end
      end
    end
  end
end
