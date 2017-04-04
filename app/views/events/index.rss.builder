# frozen_string_literal: true

# @todo only insert "views/" into our cache keys when it's needed, i.e. in the context of Mustache view classes
#cache(cache_key(@body_cache_key).sub(%r{\Aviews\/}, ''), skip_digest: true) do
xml.instruct!
xml.rss(version: '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom') do
  xml.channel do
    xml.title("Europeana - #{t('global.events')}")
    #xml.description(t('site.events.description'))
    xml.link(events_url)
    xml.language(locale.to_s)
    xml.lastBuildDate(Date.parse(@events.first.datepublish).rfc2822)
    xml.tag!('atom:link', rel: 'self', type: 'application/rss+xml', href: events_url(format: 'rss'))

    @events.each do |event|
      xml.item do
        xml.title(event.title)
        xml.link(event_url(event.slug))
        xml.description(event.teaser)
        event.taxonomy[:tags].each do |tag|
          xml.category(tag[1])
        end
        if thumb = event.teaser_image
          xml.enclosure(url: event.teaser_image.url, length: 0, type: 'image/*')
        end
        xml.guid(event_url(event.slug))
        xml.pubDate(Date.parse(event.datepublish).rfc2822)
      end
    end
  end
end
#end
