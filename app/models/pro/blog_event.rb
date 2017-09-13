# frozen_string_literal: true
module Pro
  ##
  # "Blog events" from Pro JSON API.
  class BlogEvent < Base
    def self.table_name
      'blogevents'
    end

    def has_teaser_image?
      respond_to?(:teaser_image) && teaser_image.is_a?(Hash)
    end
  end
end
