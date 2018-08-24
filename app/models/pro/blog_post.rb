# frozen_string_literal: true

module Pro
  # Blog posts from Pro JSON-API, only published here in the Portal.
  class BlogPost < Base
    def self.table_name
      'blogposts'
    end
  end
end
