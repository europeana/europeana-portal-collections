# frozen_string_literal: true

# Helper method for the collections description
# derived from the associated landing page strapline.
def strapline(collection)
  if collection.landing_page.strapline.present?
    total_item_count = Rails.cache.fetch("record/counts/collections/#{collection.key}")
    collection.landing_page.strapline(total_item_count: number_with_delimiter(total_item_count))
  end
end

xml.instruct!
xml.rss(version: '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom') do
  xml.channel do
    xml.title("Europeana - #{t('global.navigation.collections')}")
    xml.description(t('site.collections.description'))
    xml.link(collections_url)
    xml.language(locale.to_s)
    xml.lastBuildDate(DateTime.now.rfc2822)
    xml.tag!('atom:link', rel: 'self', type: 'application/rss+xml', href: collections_url(format: 'rss'))

    displayable_collections.each do |collection|
      xml.item do
        xml.title(collection.title)
        xml.link(collection_url(collection))
        xml.guid(collection_url(collection))
        xml.description(strapline(collection))
      end
    end
  end
end

