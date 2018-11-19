# frozen_string_literal: true

content = exhibition_content(@exhibition)
json.extract! content, *content.keys
