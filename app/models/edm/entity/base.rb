# frozen_string_literal: true

module EDM
  module Entity
    class Base
      include ActiveModel::Model
      include Depiction
      include I18nHelper

      attr_accessor :id, :locale, :api_response

      delegate :t, to: I18n

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

        def humanized_as(human_type)
          @human_type = human_type
        end
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
