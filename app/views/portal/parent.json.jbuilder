# frozen_string_literal: true

json.url document_path(@parent['id'])
json.relation 'Parent item'
json.title @parent['title']
json.attribution @parent['dataProvider']
json.excerpt do
  json.short Europeana::API::Record::LangMap.localise_lang_map(@parent['dcDescriptionLangAware'])
end
json.img do
  json.src @parent['edmPreview']
end
