# frozen_string_literal: true
class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :name
      t.string :slug, index: true
      t.string :url
      t.timestamps null: false
    end

    reversible do |change|
      change.up do
        Feed.create!(
            name: 'Fashion Tumblr',
            url: 'http://europeanafashion.tumblr.com/rss'
        )
      end
    end
  end
end
