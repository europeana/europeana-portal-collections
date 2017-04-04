# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Pro RSS feeds' do
  context 'blog posts' do
    describe 'blog_posts rss feed' do
      it 'should be present and valid' do
        visit '/en/blogs.rss'

        parsed_feed = Feedjira::Feed.parse_with(Feedjira::Parser::RSS, page.body)

        expect(parsed_feed.title).to eq('Europeana - Blogs')
        expect(parsed_feed.url).to eq('http://www.example.com/en/blogs')
        expect(parsed_feed.entries.count).to be > 0
      end
    end
  end

  context 'events rss feed' do
    describe 'events rss feed' do
      it 'should be present and valid' do
        visit '/en/blogs.rss'

        parsed_feed = Feedjira::Feed.parse_with(Feedjira::Parser::RSS, page.body)

        expect(parsed_feed.title).to eq('Europeana - Blogs')
        expect(parsed_feed.url).to eq('http://www.example.com/en/blogs')
        expect(parsed_feed.entries.count).to be > 0
      end
    end
  end
end
