# frozen_string_literal: true

json.url portal_entity_path(@entity.uri, format: 'html')
json.img do
  json.src @entity.thumbnail_src
end
json.overlay do
  json.title @entity.pref_label
  json.description @entity.description
end
