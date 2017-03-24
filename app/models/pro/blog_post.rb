# frozen_string_literal: true
module Pro
  ##
  # Blog posts from Pro JSON-API.
  class BlogPost < Base
    def self.table_name
      'blogposts'
    end

    def has_authors?
      includes?(:network) || includes?(:persons)
    end

    def has_image?
      respond_to?(:image) && image.is_a?(Hash)
    end
  end
end
