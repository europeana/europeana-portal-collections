# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Pro RSS feeds' do
  # let(:json_api_content_type) { 'application/vnd.api+json' }
  #
  # before do
  #   stub_request(:get, json_api_url).
  #       with(headers: {
  #           'Accept' => json_api_content_type,
  #           'Content-Type' => json_api_content_type
  #       }).
  #       to_return(
  #           status: 200,
  #           body: response_body,
  #           headers: { 'Content-Type' => json_api_content_type }
  #       )
  # end
  #
  # context 'blog posts' do
  #   let(:json_api_url) { %r{\A#{Rails.application.config.x.europeana[:pro_url]}/json/blogposts(\?|\z)} }
  #   let(:response_body) { '{"meta": {"count": 0, "total": 0}, "data": [ { "id": 1, "type": "blogposts" } ]}' }
  #
  #   describe 'blog_posts rss feed' do
  #     it 'should be present and valid' do
  #       visit '/en/blogs.rss'
  #
  #       puts page.body
  #       parsed_feed = Feedjira::Feed.parse_with(Feedjira::Parser::RSS, page.body)
  #
  #       expect(parsed_feed.title).to eq('Europeana - Blogs')
  #       expect(parsed_feed.url).to eq('http://www.example.com/en/blogs')
  #       expect(parsed_feed.entries.count).to be > 0
  #     end
  #   end
  # end
  #
  # context 'events' do
  #   let(:json_api_url) { %r{\A#{Rails.application.config.x.europeana[:pro_url]}/json/events(\?|\z)} }
  #   let(:response_body) { '{"meta": {"count": 1, "total": 1}, "data": [{ "id": "1", "type": "events" }]}' }
  #
  #   describe 'events rss feed' do
  #     it 'should be present and valid' do
  #       visit '/en/events.rss'
  #
  #       parsed_feed = Feedjira::Feed.parse_with(Feedjira::Parser::RSS, page.body)
  #
  #       expect(parsed_feed.title).to eq('Europeana - Events')
  #       expect(parsed_feed.url).to eq('http://www.example.com/en/blogs')
  #       expect(parsed_feed.entries.count).to be > 0
  #     end
  #   end
  # end
end
