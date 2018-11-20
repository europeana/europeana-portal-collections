# frozen_string_literal: true

module ParentHelper
  def parent_promo_content(parent_item)
    return nil if parent_item.blank?

    {
      url: document_path(parent_item['id'][1..-1]),
      title: parent['title'],
      description: Europeana::API::Record::LangMap.localise_lang_map(parent['dcDescriptionLangAware']),
      images: [parent['edmPreview']],
      media_type: parent['type'].downcase
    }
  end
end
