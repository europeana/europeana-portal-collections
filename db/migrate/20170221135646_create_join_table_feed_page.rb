# frozen_string_literal: true
class CreateJoinTableFeedPage < ActiveRecord::Migration
  def change
    create_join_table :feeds, :pages do |t|
      t.index [:feed_id, :page_id]
      t.index [:page_id, :feed_id]
    end
    reversible do |change|
      change.up do
        if Page::Landing.find_by_slug('collections/fashion').present?
          fashion_page = Page::Landing.find_by_slug('collections/fashion')
          fashion_page.feeds << Feed.find_by_slug('fashion-tumblr')
          fashion_page.save
        end
      end
    end
  end
end
