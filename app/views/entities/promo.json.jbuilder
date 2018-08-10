# frozen_string_literal: true

# presenter = EntityPresenter.new(@entity)

json.url portal_entity_path(@entity.uri, format: 'html')
json.title false
json.img do
  json.src @entity.thumbnail_src
end
json.overlay do
  json.title @entity.pref_label
  json.description @entity.description
end
