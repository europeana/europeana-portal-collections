# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Collection search page' do
  [false, true].each do |js|
    context (js ? 'with JS' : 'without JS'), js: js do
      describe 'collection search page' do
        it 'allows removal of the collection filter' do
          visit '/en/collections/music?q='

          expect(page).to have_selector(:xpath, "//section[contains(@class, 'search-hero')]//ul[contains(@class, 'facets-selected')]/li[contains(@class, 'search-tag') and contains(., 'Music')]/span[contains(@class, 'title') and contains(., 'Collections')]")
          expect(page).to have_selector(:xpath, "//section[contains(@class, 'search-hero')]//ul[contains(@class, 'facets-selected')]/li[contains(@class, 'search-tag') and contains(., 'Music')]/a[contains(@href, 'en/search?q=')]")
        end
      end
    end
  end
end
