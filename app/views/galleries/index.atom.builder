def entry_summary(gallery)
  image_count = gallery.images.count
  document = @documents.detect { |document| document.fetch(:id, nil) == gallery.images.first.europeana_record_id }
  presenter = Document::SearchResultPresenter.new(document, controller)
  image_url = presenter.field_value('edmPreview')
  "<h2>#{gallery.title} <span>(#{image_count} #{t('global.labels.images')})</span></h2><img src=\"#{image_url}\"/><p>#{gallery.description}<p>"
end

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
