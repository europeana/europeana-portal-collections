# frozen_string_literal: true

class NavCacheInvalidationObserver < ActiveRecord::Observer
  include CacheHelper

  observe :collection, :gallery

  def after_save(_)
    expire_nav_cache
  end

  def after_destroy(_)
    expire_nav_cache
  end

  private

  def expire_nav_cache
    expire_cache(NavigableView::GLOBAL_PRIMARY_NAV_ITEMS_CACHE_KEY)
  end
end
