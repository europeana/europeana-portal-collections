# frozen_string_literal: true

json.array! @galleries do |gallery|
  content = gallery_content(gallery)
  json.extract! content, *content.keys
end
