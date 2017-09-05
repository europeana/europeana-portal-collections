# frozen_string_literal: true

module EDM
  module Entity
    class Base
      include ActiveModel::Model
      include I18nHelper

      attr_accessor :id, :locale, :api_response

      class << self
        attr_reader :human_type

        def subclass_for_human_type(human_type)
          case human_type
          when 'period'
            EDM::Entity::Timespan
          when 'person'
            EDM::Entity::Agent
          when 'place'
            EDM::Entity::Place
          when 'topic'
            EDM::Entity::Concept
          else
            fail ArgumentError, %(Human entity type unknown: "#{human_type}")
          end
        end

        protected

        def has_human_type(human_type)
          @human_type = human_type
        end
      end

      def depiction_source
        api_response.key?(:depiction) ? api_response[:depiction][:source] : nil
      end

      def has_depiction?
        api_response.key?(:depiction) &&
          api_response[:depiction].is_a?(Hash) &&
          api_response[:depiction].key?(:id)
      end

      def thumbnail
        return nil unless has_depiction?

        full = api_response[:depiction][:id]

        thumbnail_urls = full.match(%r{^.*/Special:FilePath/(.*)$}i)
        return nil if thumbnail_urls.nil?

        src = build_src(thumbnail_urls[1], 400)
        { src: src, full: full, alt: thumbnail_urls[1] }
      end

      def description
        nil
      end

      # @return [String] localised prefLabel
      def pref_label
        pl = api_response[:prefLabel]
        if pl && pl.is_a?(Hash) && pl.present?
          localised_pl = pl[locale] || pl[I18n.default_locale]
          [localised_pl].flatten.first
        end
      end

      private

      # Returns a string
      def value_by_locale(list)
        return nil unless list.present?

        # Ensure that list is a valid array
        list = [list] if list.is_a?(Hash)
        return nil unless list.is_a?(Array) && list.first.is_a?(Hash)

        item = list.detect { |l| l['@language'] == locale }
        item ||= list.detect { |l| l['@language'] == I18n.default_locale.to_s }

        item.present? && item.key?('@value') ? item['@value'] : nil
      end

      # Returns an array of strings
      def values_by_id(list)
        return nil unless list.present?

        # Ensure that list is a valid array
        list = [list] if list.is_a?(Hash)
        return nil unless list.is_a?(Array) && list.first.is_a?(Hash)

        list.map { |l| l['@id'] }.reject(&:nil?)
      end

      # Returns either a string or an array of strings, depending on whether
      # a single @language value has been found or a list of @ids.
      def value(list)
        value_by_locale(list) || values_by_id(list) || nil
      end

      # Returns a string
      def place(place)
        result = value(place)
        result.is_a?(Array) ? format_resource_urls(result).join(', ') : result
      end

      def date_and_place(date, place)
        result = [date, place].compact
        result.blank? ? nil : result
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
      def build_src(image, size)
        underscored_image = URI.unescape(image).tr(' ', '_')
        md5 = Digest::MD5.hexdigest(underscored_image)
        "https://upload.wikimedia.org/wikipedia/commons/thumb/#{md5[0]}/#{md5[0..1]}/#{underscored_image}/#{size}px-#{underscored_image}"
      end

      # Takes an array of results of the form:
      #
      # [ "http://dbpedia.org/resource/_Pianist",
      #   "http://dbpedia.org/resource/opera_singer",
      #   "Some junk",
      #   "http://dbpedia.org/resource/Composer" ]
      #
      # to:
      #
      # [ "Pianist",
      #   "Opera singer",
      #   "Composer" ]
      #
      # Returns an array of strings
      def format_resource_urls(results)
        results.
          map { |l| l.match(%r{[^\/]+$}) }.
          reject(&:nil?).
          map { |s| s[0] }.
          map { |s| URI.unescape(s) }.
          map { |s| s.sub(/^_/, '') }.
          map { |s| s.sub(/_$/, '') }.
          map { |s| s.tr('_', ' ') }
      end

      def date(dates)
        return nil unless dates.present?
        (date_most_accurate(dates) || dates.first).strip
      end
    end
  end
end
