module RecordHelper
  include ThumbnailHelper

  def more_like_this(similar)
    similar.map do |doc|
      {
        url: document_path(doc, format: 'html'),
        title: presenter(doc).field_value(%w(dcTitleLangAware title)),
        img: {
          alt: presenter(doc).field_value(%w(dcTitleLangAware title)),
          # temporary fix until API contains correct image url
          # src: render_document_show_field_value(doc, 'edmPreview'),
          src: thumbnail_url_for_edm_preview(presenter(doc).field_value('edmPreview'), size: 400)
        }
      }
    end
  end

  def paginated_more_like_this(response, similar)
    {
      page: response.current_page,
      per_page: response.limit_value,
      total: response.total_count,
      documents: more_like_this(similar)
    }
  end

  # @todo Refactor for raw API data
  def record_hierarchy(hierarchy)
    hierarchy.to_json
#    if hierarchy.is_a?(Hash)
#      {
#        parent: hierarchy_node(hierarchy[:parent]),
#        siblings: {
#          items: hierarchy[:preceding_siblings].map { |item| hierarchy_node(item) } +
#            [hierarchy_node(hierarchy[:self])] +
#            hierarchy[:following_siblings].map { |item| hierarchy_node(item) }
#        },
#        children: {
#          items: hierarchy[:children].map { |item| hierarchy_node(item) }
#        }
#      }
#    elsif hierarchy.is_a?(Array)
#      hierarchy.map { |item| hierarchy_node(item) }
#    else
#      hierarchy_node(hierarchy)
#    end
  end

  def hierarchy_node(item)
    return nil unless item.present?
    {
      title: presenter(doc).field_value(item, 'title'),
      index: presenter(doc).field_value(item, 'index'),
      url: document_path(item, format: 'html'),
      is_current: (item.id == @document.id)
    }
  end

  def record_media_items(record, options = {})
    Document::RecordPresenter.new(record, controller).media_web_resources(options).map(&:media_item)
  end

  def record_annotations(annotations)
    return nil if annotations.blank?
    {
      title: t('annotations', scope: 'site.object.meta-label'),
      info: static_page_path('annotations', format: 'html'),
      sections: [
        {
          items: annotations.map { |anno| { url: anno, text: anno } },
          title: t('site.object.meta-label.relations')
        }
      ]
    }
  end
end
