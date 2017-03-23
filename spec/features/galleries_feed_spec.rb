# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Galleries atom feed' do
  describe 'galleries atom feed' do
    it 'should be present and valid' do
      visit '/en/explore/galleries.atom'

      parsed_feed = Feedjira::Feed.parse_with(Feedjira::Parser::Atom, page.body)

      expect(parsed_feed.title).to eq('Europeana - Galleries')
      expect(parsed_feed.url).to eq('http://www.example.com')
      expect(parsed_feed.entries.count).to  be > 0
    end
  end

  describe 'galleries atom feed entries' do
    it 'should have correct entries for each published gallery' do
      visit '/en/explore/galleries.atom'

      parsed_feed = Feedjira::Feed.parse_with(Feedjira::Parser::Atom, page.body)
      empty_entry = parsed_feed.entries.detect { |entry| entry.id.include?("Gallery/#{galleries(:empty).id}")}
      curated_entry = parsed_feed.entries.detect { |entry| entry.id.include?("Gallery/#{galleries(:curated_gallery).id}")}
      fashion_entry = parsed_feed.entries.detect { |entry| entry.id.include?("Gallery/#{galleries(:fashion_dresses).id}")}

      expect(empty_entry).to_not be(nil)
      expect(empty_entry.summary).to include(galleries(:empty).title)
      expect(curated_entry).to_not be(nil)
      expect(curated_entry.summary).to include('<h2> <span>(0 images)</span></h2>')
      expect(fashion_entry).to_not be(nil)
      expect(fashion_entry.summary).to include(galleries(:fashion_dresses).title)
      expect(fashion_entry.summary).to include('(2 images)')
    end
  end

  describe 'filtering by theme' do
    it 'should be present and valid' do
      visit '/en/explore/galleries.atom?theme=fashion'

      parsed_feed = Feedjira::Feed.parse_with(Feedjira::Parser::Atom, page.body)

      fashion_entry = parsed_feed.entries.detect { |entry| entry.id.include?("Gallery/#{galleries(:fashion_dresses).id}")}
      
      expect(fashion_entry).to_not be(nil)
      expect(parsed_feed.entries.count).to  eq(1)
    end
  end
end
