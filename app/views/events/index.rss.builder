# frozen_string_literal: true
xml.instruct!
xml.rss(version: '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'xmlns:ev' => 'http://purl.org/rss/1.0/modules/event/') do
  xml.channel do
    xml.title("Europeana - Events")
    xml.description(t('site.events.description'))
    xml.link(events_url)
    xml.language(locale.to_s)
    xml.lastBuildDate(DateTime.parse(@events.first.datepublish).rfc2822)
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
          xml.enclosure(url: thumb[:url], length: 0, type: 'image/*')
        end
        xml.guid(event_url(event.slug))
        xml.pubDate(DateTime.parse(event.datepublish).rfc2822)
        xml.ev(:startdate, DateTime.parse(event.start_event).iso8601)
        xml.ev(:enddate, DateTime.parse(event.end_event).iso8601)
        xml.ev(:location, event.locations.first.title)
      end
    end
  end
end
