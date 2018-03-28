# frozen_string_literal: true

class CreateJoinTableFeedPage < ActiveRecord::Migration
  def change
    create_join_table :feeds, :pages do |t|
      t.index %i(feed_id page_id)
      t.index %i(page_id feed_id)
    end
    reversible do |change|
      change.up do
        if Page::Landing.find_by_slug('').present?
          page = Page::Landing.find_by_slug('')
          page.feeds << Feed.find_by_slug('all-blog')
          page.save
        end
        if Page::Landing.find_by_slug('collections/art').present?
          fashion_page = Page::Landing.find_by_slug('collections/art')
          fashion_page.feeds << Feed.find_by_slug('art-blog')
          fashion_page.save
        end
        if Page::Landing.find_by_slug('collections/music').present?
          fashion_page = Page::Landing.find_by_slug('collections/music')
          fashion_page.feeds << Feed.find_by_slug('music-blog')
          fashion_page.save
        end
        if Page::Landing.find_by_slug('collections/fashion').present?
          fashion_page = Page::Landing.find_by_slug('collections/fashion')
          fashion_page.feeds << Feed.find_by_slug('fashion-tumblr')
          fashion_page.feeds << Feed.find_by_slug('fashion-blog')
          fashion_page.save
        end
      end
    end
  end
end
