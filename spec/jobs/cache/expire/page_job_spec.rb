# frozen_string_literal: true

RSpec.describe Cache::Expiry::PageJob do
  include CacheHelper

  let(:page) { pages(:music_collection) }
  context 'when the page is cached' do
    let(:page_cache_key) do
      cache_key(page.cache_key, locale: 'en', user_role: 'guest')
    end
    let(:page_cache_content) { 'cached page' }

    before do
      Rails.cache.write(page_cache_key, page_cache_content)
    end

    it 'expires the cache entry' do
      expect { subject.perform(page.id) }.to change { Rails.cache.fetch(page_cache_key) }.from(page_cache_content).to(nil)
    end
  end
end
