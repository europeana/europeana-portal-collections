# frozen_string_literal: true
module Pro
  ##
  # Events from Pro JSON API.
  class Event < Base
    def has_teaser_image?
      respond_to?(:teaser_image) && teaser_image.is_a?(Hash)
    end
  end
end
