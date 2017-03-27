# frozen_string_literal: true
self.class.send(:include, GalleryDisplayingView)

def entry_summary(gallery)
  image_count = gallery.images.count
  unless image_count.zero?
    presenter = presenter_for_gallery_image(gallery.images.first)
    image_url = presenter.field_value('edmPreview')
  end
  image_url ||= @hero_image && @hero_image.file.present? ? @hero_image.file.url : nil

  %[
    <h2>#{gallery.title} <span>(#{image_count} #{t('global.labels.images')})</span></h2>
    <img src=\"#{image_url}\"/>
    <p>#{gallery.description}<p>
  ]
end

# @todo only insert "views/" into our cache keys when it's needed, i.e. in the context of Mustache view classes
cache(cache_key(@body_cache_key).sub(%r{\Aviews\/}, ''), skip_digest: true) do
  atom_feed do |feed|
    feed.title "Europeana - #{t('global.galleries')}"
    feed.updated @galleries.maximum(:published_at)

    @galleries.each do |gallery|
      feed.entry(gallery) do |entry|
        entry.title(gallery.title)
        entry.content(type: 'text/html', src: gallery_url(gallery))
        entry.author do |author|
          author.name(gallery.publisher)
        end
        entry.summary(entry_summary(gallery), type: 'html')
      end
    end
  end
end
