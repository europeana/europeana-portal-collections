# frozen_string_literal: true

module ParentHelper
  def parent_promo_content(parent_item)
    return nil if parent_item.blank?

    {
      url: document_path(parent_item['id'][1..-1]),
      title: parent_item['title'].is_a?(Array) ? parent_item['title'].first : parent_item['title'],
      description: Europeana::API::Record::LangMap.localise_lang_map(parent_item['dcDescriptionLangAware']),
      images: [parent_item['edmPreview']],
      media_type: parent_item['type']&.downcase
    }
  end
end
