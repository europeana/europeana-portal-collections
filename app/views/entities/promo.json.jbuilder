# frozen_string_literal: true

json.img do
  json.src @entity.thumbnail_src
end
json.overlay do
  json.title @entity.pref_label
  json.description @entity.description
  json.link_more do
    json.url portal_entity_path(@entity.uri, format: 'html')
    json.text t('global.more.view-more')
  end
end
