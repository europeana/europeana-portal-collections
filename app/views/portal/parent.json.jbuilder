# frozen_string_literal: true

json.url document_path(@parent['id'][1..-1])
json.relation 'Parent item'
json.title @parent['title']
json.excerpt do
  json.short Europeana::API::Record::LangMap.localise_lang_map(@parent['dcDescriptionLangAware'])
end
json.img do
  json.src @parent['edmPreview']
end
json.is_3d @parent['type'] == '3D'
json.is_audio @parent['type'] == 'SOUND'
json.is_image @parent['type'] == 'IMAGE'
json.is_text @parent['type'] == 'TEXT'
json.is_video @parent['type'] == 'VIDEO'
