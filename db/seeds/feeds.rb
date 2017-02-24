# frozen_string_literal: true
unless Feed.find_by_slug('fashion-tumblr').present?
  Feed.create!(
      name: 'Fashion Tumblr',
      url: 'http://europeanafashion.tumblr.com/rss'
  )

  # if the landing page is already present we need to add our feed to it here
  if Page::Landing.find_by_slug('collections/fashion').present?
    fashion_page = Page::Landing.find_by_slug('collections/fashion')
    fashion_page.feeds << Feed.find_by_slug('fashion-tumblr')
    fashion_page.save
  end
end