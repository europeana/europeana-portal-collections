module RecordHelper
  def more_like_this(similar)
    similar.map do |doc|
      {
        url: document_path(doc, format: 'html'),
        title: render_document_show_field_value(doc, ['dcTitleLangAware', 'title']),
        img: {
          alt: render_document_show_field_value(doc, ['dcTitleLangAware', 'title']),
          src: render_document_show_field_value(doc, 'edmPreview')
        }
      }
    end
  end
end
