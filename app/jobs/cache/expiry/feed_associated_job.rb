# frozen_string_literal: true

module Cache
  module Expiry
    ##
    # Job to expire the cached version of a page
    class FeedAssociatedJob < ApplicationJob
      queue_as :cache

      def perform(url)
        GlobalNavJob.perform_later if NavigableView.feeds_included_in_nav_urls.include?(@url)
        Page.joins(:feeds).where('feeds.url' => @url).references(:feeds).each do |page|
          Cache::Expiry::PageJob.perform_later(page.id)
        end
      end
    end
  end
end
