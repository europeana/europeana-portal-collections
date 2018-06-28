# frozen_string_literal: true

module Europeana
  class Record
    # A set of Europeana records
    #
    # TODO: store on the Sets API once implemented?
    class Set < ActiveRecord::Base
      include HasSettingsAttribute

      self.table_name = 'europeana_record_sets'

      has_one :page_element, dependent: :destroy, as: :positionable
      has_one :page, through: :page_element

      after_save do
        page.touch
      end

      validates :europeana_ids, presence: true
      validates :title, presence: true
      validate :validate_portal_urls_presence, :validate_portal_urls_format

      has_settings :query_term

      def portal_urls
        europeana_ids&.map { |id| Europeana::Record.portal_url(id) }
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

      def query_term
        settings_query_term.present? ? settings_query_term : title
      end

      protected

      def validate_portal_urls_presence
        errors.add(:portal_urls_text, ::I18n.t('errors.messages.blank')) unless portal_urls_text.present?
      end

      def validate_portal_urls_format
        return unless @portal_urls_to_europeana_ids.present?
        @portal_urls_to_europeana_ids.each_pair do |url, europeana_id|
          errors.add(:portal_urls_text, %(on set "#{title}", invalid portal URL: #{url})) if europeana_id.nil?
        end
      end
    end
  end
end
