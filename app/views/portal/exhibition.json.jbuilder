# frozen_string_literal: true

content = exhibition_content(@exhibition)
json.exhibition_promo do
  json.extract! content, *content.keys
end
