# frozen_string_literal: true

json.url document_path(@parent['id'])
json.relation 'Parent item'
json.title @parent['title']
json.attribution @parent['dataProvider']
json.img do
  json.src @parent['edmPreview']
end
