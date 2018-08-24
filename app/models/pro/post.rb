# frozen_string_literal: true

module Pro
  # Blog posts from Pro JSON-API, published on Pro.
  class Post < Base
    def self.table_name
      'posts'
    end
  end
end
