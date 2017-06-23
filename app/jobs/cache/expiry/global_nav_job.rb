# frozen_string_literal: true

module Cache
  module Expiry
    ##
    # Job to expire the cached global nav entries
    class GlobalNavJob < ApplicationJob
      include CacheHelper

      queue_as :cache

      def perform
        expire_cache(NavigableView::GLOBAL_PRIMARY_NAV_ITEMS_CACHE_KEY)
      end
    end
  end
end
