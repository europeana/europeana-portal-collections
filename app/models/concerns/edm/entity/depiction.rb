# frozen_string_literal: true

module EDM
  module Entity
    module Depiction
      extend ActiveSupport::Concern

      def thumbnail_filename
        @thumbnail_filename ||= begin
          m = thumbnail_full&.match(%r{^.*/Special:FilePath/(.*)$}i)
          m.nil? ? nil : m[1]
        end
      end

      def thumbnail_src
        wikimedia_thumbnail_url(thumbnail_filename, 400)
      end

      def thumbnail_full
        api_response.dig(:depiction, :id)
      end

      def depiction_source
        api_response.dig(:depiction, :source)
      end

      def has_depiction?
        api_response.key?(:depiction) &&
          api_response[:depiction].is_a?(Hash) &&
          api_response[:depiction].key?(:id)
      end

      # The logic for going from: http://commons.wikimedia.org/wiki/Special:FilePath/[image] to
      # https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/[image]/200px-[image] is the following:
      #
      # The first part is always the same: https://upload.wikimedia.org/wikipedia/commons/thumb
      # The second part is the first character of the MD5 hash of the file name. In this case, the MD5 hash
      # of Tour_Eiffel_Wikimedia_Commons.jpg is a85d416ee427dfaee44b9248229a9cdd, so we get /a.
      # NB: File names will first have space characters " " replaced with underscores "_".
      # The third part is the first two characters of the MD5 hash from above: /a8.
      # The fourth part is the file name: /[image]
      # The last part is the desired thumbnail width, and the file name again: /200px-[image]
      #
      # @param image [String] the image file name extracted from the URL path
      # @param size [Fixnum] size of the image required
      # @return [String]
      # @see https://meta.wikimedia.org/wiki/Thumbnails#Dynamic_image_resizing_via_URL
      def wikimedia_thumbnail_url(image, size)
        return nil unless image.is_a?(String)
        underscored_image = URI.unescape(image).tr(' ', '_')
        md5 = Digest::MD5.hexdigest(underscored_image)
        "https://upload.wikimedia.org/wikipedia/commons/thumb/#{md5[0]}/#{md5[0..1]}/#{underscored_image}/#{size}px-#{underscored_image}"
      end
    end
  end
end
