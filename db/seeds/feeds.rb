# frozen_string_literal: true
unless Feed.find_by_slug('fashion-tumblr').present?
  Feed.create!(
      name: 'Fashion Tumblr',
      url: 'http://europeanafashion.tumblr.com/rss'
  )
end