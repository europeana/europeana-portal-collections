# frozen_string_literal: true

RSpec.describe Cache::Expiry::GlobalNavJob do
  include CacheHelper

  context 'when global nav is cached' do
    let(:nav_cache_key) do
      cache_key(NavigableView::GLOBAL_PRIMARY_NAV_ITEMS_CACHE_KEY, locale: 'en', user_role: 'guest')
    end
    let(:nav_cache_content) { 'cached nav' }

    before do
      Rails.cache.write(nav_cache_key, nav_cache_content)
    end

    it 'expires the cache entry' do
      expect { subject.perform }.to change { Rails.cache.fetch(nav_cache_key) }.from(nav_cache_content).to(nil)
    end
  end
end
