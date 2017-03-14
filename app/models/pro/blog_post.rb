# frozen_string_literal: true
module Pro
  ##
  # Blog posts from Pro JSON-API.
  class BlogPost < Base
    def self.table_name
      'blogposts'
    end

    def to_param
      slug
    end
  end
end
