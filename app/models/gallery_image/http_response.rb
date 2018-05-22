# frozen_string_literal: true

class GalleryImage
  module HTTPResponse
    extend ActiveSupport::Concern

    include MediaProxyHelper
    include MayValidateMayNot

    included do
      may_validate_with :http_response
      validate :validate_http_image, if: :validating_with_http_response?
    end

    def validate_http_image
      unless http_image_content_type?
        errors.add(:url, %(HTTP response is not an image for "#{url}"))
      end
    end

    # Is the HTTP response from +url+ an image?
    #
    # Inspects the Content-Type header to see if it starts with "image".
    def http_image_content_type?
      return false unless http_response&.success?
      http_response.headers[:content_type]&.start_with?('image')
    end

    # Retrieve the HTTP response for +url+
    #
    # Will first attempt a HEAD request. If that fails, will attempt a GET request.
    #
    # @param force Force re-requesting the HTTP response.
    # @return [RestClient::Response] The HTTP response, or nil if not retrievable.
    def http_response(force: false)
      return @http_response unless force || !instance_variable_defined?(:@http_response)

      http_url = media_proxy_url(europeana_record_id, url)

      @http_response = Faraday.head(http_url)
      @http_response = Faraday.get(http_url) unless @http_response.success?
      @http_response
    end
  end
end
