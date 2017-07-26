# frozen_string_literal: true

module Cache
  module Expiry
    ##
    # Job to expire the cached version of a page
    class PageJob < ApplicationJob
      include CacheHelper

      queue_as :cache

      def perform(page_id = nil)
        expire_cache(Page.find(page_id).cache_key)
      end
    end
  end
end
