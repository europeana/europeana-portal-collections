# frozen_string_literal: true

RSpec.feature 'Newspapers collection' do
  let(:collection) { collections(:newspapers) }
  include_context :collection_with_custom_api_url

  describe 'search' do
    it 'has an API toggle' do
      visit collection_path(collection, locale: 'en', q: '')

      expect(page).to have_css('.filter-list a.is-checked .filter-text', text: 'Fulltext')
      expect(page).to have_css('.filter-list a:not(.is-checked) .filter-text', text: 'Metadata')
    end
  end
end
