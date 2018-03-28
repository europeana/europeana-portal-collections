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
          name: 'All Blog',
          url: 'http://blog.europeana.eu/feed/'
        )
        Feed.create!(
          name: 'Art Blog',
          url: 'http://blog.europeana.eu/tag/art/feed/'
        )
        Feed.create!(
          name: 'Music Blog',
          url: 'http://blog.europeana.eu/tag/music/feed/'
        )
        Feed.create!(
          name: 'Fashion Blog',
          url: 'http://blog.europeana.eu/tag/fashion/feed/'
        )
        Feed.create!(
          name: 'Fashion Tumblr',
          url: 'http://europeanafashion.tumblr.com/rss'
        )
      end
    end
  end
end
