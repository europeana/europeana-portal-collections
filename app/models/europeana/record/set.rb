# frozen_string_literal: true

module Europeana
  class Record
    # A set of Europeana records
    #
    # TODO: store on the Sets API once implemented?
    class Set < ActiveRecord::Base
      self.table_name = 'europeana_record_sets'

      has_one :page_element, dependent: :destroy, as: :positionable
      has_one :page, through: :page_element

      after_save do
        page_element&.touch
      end

      translates :pref_label, fallbacks_for_empty_translations: true
      accepts_nested_attributes_for :translations, allow_destroy: true
      default_scope { includes(:translations) }

      validates :europeana_ids, presence: true
      validates :pref_label, presence: true
      validate :validate_portal_urls_presence, :validate_portal_urls_format

      store_accessor :settings, :query_term

      def portal_urls
        europeana_ids&.map { |id| Europeana::Record.portal_url(id) }
      end

      delegate :position, to: :page_element, allow_nil: true

      def position=(value)
        page_element&.update_attribute(:position, value.to_i)
      end

      # Set Europeana IDs from portal URLs
      #
      # @param value [Array<String>]
      def portal_urls=(value)
        @portal_urls_to_europeana_ids = value.each_with_object({}) do |url, memo|
          memo[url] = Europeana::Record.id_from_portal_url(url)
        end
        self.europeana_ids = @portal_urls_to_europeana_ids.values.compact
      end

      def portal_urls_text
        @portal_urls_text || portal_urls&.join("\n\n")
      end

      def portal_urls_text=(value)
        @portal_urls_text = value
        self.portal_urls = value&.split(/\s+/)
      end

      def query_term_with_fallback
        query_term.present? ? query_term : pref_label || ''
      end

      # Construct a full search query, with the page's base query
      #
      # Will call and return from +#default_set_query+ if query would otherwise
      # be blank.
      #
      # @return [String,Nil] portal search query string, or nil if
      #   +set_query+ is blank
      def full_query
        [page.base_query, formatted_query].compact.join('&')
      end

      # Construct a per-set query, without the page's base query
      #
      # The per-set query is constructed by interpolating +#query_term+ into
      # +page.set_query+ if present, else falls back to +#default_query+.
      #
      # @return [String] portal search query string for the set
      def formatted_query
        if page.set_query.present?
          format(page.set_query, set_query_term: CGI.escape(query_term_with_fallback))
        else
          default_query
        end
      end

      # Construct a default set query
      #
      # A default set query simply includes the set's query term in the `q` URL
      # parameter.
      #
      # @return [String]
      def default_query
        'q=' + CGI.escape(query_term_with_fallback)
      end

      protected

      def validate_portal_urls_presence
        errors.add(:portal_urls_text, ::I18n.t('errors.messages.blank')) unless portal_urls_text.present?
      end

      def validate_portal_urls_format
        return unless @portal_urls_to_europeana_ids.present?
        @portal_urls_to_europeana_ids.each_pair do |url, europeana_id|
          errors.add(:portal_urls_text, %(on set "#{pref_label}", invalid portal URL: #{url})) if europeana_id.nil?
        end
      end
    end
  end
end
