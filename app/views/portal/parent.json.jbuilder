# frozen_string_literal: true

json.url document_path(@parent['id'][1..-1])
json.relation t('site.object.promotions.card-labels.dctermsIsPartOf')
json.title @parent['title']
json.excerpt do
  json.short Europeana::API::Record::LangMap.localise_lang_map(@parent['dcDescriptionLangAware'])
end
json.img do
  json.src @parent['edmPreview']
end
json.media_type @parent['type'].downcase
