# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Collections rss feed' do
  describe 'collections rss feed' do
    it 'returns a vaild rss feed' do
      visit '/en/collections.rss'
      parsed_feed = Feedjira::Feed.parse_with(Feedjira::Parser::RSS, page.body)

      expect(parsed_feed.title).to eq('Europeana - Collections')
      expect(parsed_feed.url).to eq('http://www.example.com/en/collections')
      expect(parsed_feed.entries.count).to be > 0
    end

    it 'shows published collections with landing pages' do
      visit '/en/collections.rss'
      parsed_feed = Feedjira::Feed.parse_with(Feedjira::Parser::RSS, page.body)

      detected_entry = parsed_feed.entries.detect { |entry| entry.url.include?("collections/#{collections(:fashion).key}") }
      expect(detected_entry).to_not be(nil)
    end

    it 'does NOT show unpublished collections' do
      visit '/en/collections.rss'
      parsed_feed = Feedjira::Feed.parse_with(Feedjira::Parser::RSS, page.body)

      detected_entry = parsed_feed.entries.detect { |entry| entry.url.include?("collections/#{collections(:draft).key}") }
      expect(detected_entry).to be(nil)
    end

    it 'does NOT show collections without published landing pages' do
      visit '/en/collections.rss'
      parsed_feed = Feedjira::Feed.parse_with(Feedjira::Parser::RSS, page.body)

      detected_entry = parsed_feed.entries.detect { |entry| entry.url.include?("collections/#{collections(:art).key}") }
      expect(detected_entry).to be(nil)
    end
  end
end