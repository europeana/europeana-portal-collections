# frozen_string_literal: true
self.class.send(:include, GalleryDisplayingView)

def gallery_image(gallery)
  unless gallery.images.count.zero?
    presenter = presenter_for_gallery_image(gallery.images.first)
    image_url = presenter.field_value('edmPreview')
  end
  image_url ||= @hero_image && @hero_image.file.present? ? @hero_image.file.url : nil
end

# @todo only insert "views/" into our cache keys when it's needed, i.e. in the context of Mustache view classes
cache(cache_key(@body_cache_key).sub(%r{\Aviews\/}, ''), skip_digest: true) do
  xml.instruct!
  xml.rss(version: '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom') do
    xml.channel do
      xml.title("Europeana - #{t('global.galleries')}")
      xml.description(t('site.galleries.description'))
      xml.link(galleries_url)
      xml.language(locale.to_s)
      xml.lastBuildDate(@galleries.maximum(:published_at).rfc2822)
      xml.tag!('atom:link', rel: 'self', type: 'application/rss+xml', href: galleries_url(format: 'rss'))

      @galleries.each do |gallery|
        xml.item do
          xml.title(gallery.title)
          xml.link(gallery_url(gallery))
          xml.pubDate(gallery.published_at.rfc2822)
          xml.guid(gallery_url(gallery))
          gallery.categorisations.each do |categorisation|
            xml.category(categorisation.topic_label)
          end
          xml.description(gallery.description)
        end
      end
    end
  end
end
