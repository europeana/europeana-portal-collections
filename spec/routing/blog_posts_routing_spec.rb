# frozen_string_literal: true

RSpec.describe 'routes for the blog posts controller' do
  it 'routes GET /en/blogs to blog_posts#index' do
    expect(get('/en/blogs')).to route_to('blog_posts#index', locale: 'en')
  end

  it 'routes GET /en/blogs/important-news to blog_posts#show' do
    expect(get('/en/blogs/important-news')).to route_to('blog_posts#show', locale: 'en', slug: 'important-news')
  end
end
