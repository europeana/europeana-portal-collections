# frozen_string_literal: true
##
# Models an image extracted from a remote RSS feed
class FeedEntryImage
  # Methods of `[Feedjira::Parser::RSSEntry]` feed entry to inspect for image
  # URLs
  ENTRY_ELEMENTS = %i(summary content).freeze

  # HTML tag and attribute pairs to inspect for image URLs
  TAGS_ATTRS = [
    { tag: :img, attr: :src },
    { tag: :video, attr: :poster }
  ].freeze

  # @param entry [Feedjira::Parser::RSSEntry]
  def initialize(feed_entry)
    @feed_entry = feed_entry
  end

  def thumbnail_url
    media_object.present? ? media_object.file.url(:medium) : nil
  end

  def media_object
    @media_object ||= begin
      return nil if media_object_url.nil?
      hash = MediaObject.hash_source_url(media_object_url)
      MediaObject.find_by_source_url_hash(hash)
    end
  end

  def media_object_url
    @media_object_url ||= find_url_in_feed_entry
  end

  protected

  def find_url_in_feed_entry
    TAGS_ATTRS.each do |tag_attr|
      url = first_url_attr(tag_attr[:tag], tag_attr[:attr])
      return url unless url.nil?
    end
    nil
  end

  def element_html(element_name)
    Nokogiri::HTML(@feed_entry.send(element_name))
  end

  def first_tag_in_element(element_name, tag_name)
    element_html(element_name).css(tag_name).first
  end

  def first_attr_on_element(element_name, tag_name, attr_name)
    first_tag = first_tag_in_element(element_name, tag_name)
    first_tag.nil? ? nil : first_tag[attr_name]
  end

  def first_url_attr_on_element(element_name, tag_name, attr_name)
    attr_value = first_attr_on_element(element_name, tag_name, attr_name)
    (attr_value.present? && attr_value =~ %r{\Ahttps?://}) ? attr_value : nil
  end

  def first_url_attr(tag_name, attr_name)
    ENTRY_ELEMENTS.each do |element_name|
      url_attr = first_url_attr_on_element(element_name, tag_name, attr_name)
      return url_attr unless url_attr.nil?
    end
    nil
  end
end
