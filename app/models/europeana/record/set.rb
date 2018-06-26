# frozen_string_literal: true

module Europeana
  class Record
    # A set of Europeana records
    #
    # TODO: store on the Sets API once implemented?
    # TODO: move portal URLs handling into model concern?
    # TODO: validate portal URLs / Europeana IDs
    class Set < ActiveRecord::Base
      include HasSettingsAttribute

      self.table_name = 'europeana_record_sets'

      has_one :page_element, dependent: :destroy, as: :positionable
      has_one :page, through: :page_element

      validates :europeana_ids, presence: true
      # TODO: validate uniqueness in scope of page with custom validation method
      #       because ActiveRecord's scope option does not work on `has_one through`
      validates :title, presence: true

      has_settings :query_term

      def portal_urls
        europeana_ids&.map { |id| Europeana::Record.portal_url(id) }
      end

      def portal_urls=(value)
        self.europeana_ids = value&.map { |url| Europeana::Record.id_from_portal_url(url) }
      end

      def portal_urls_text
        portal_urls&.join("\n\n")
      end

      def portal_urls_text=(value)
        self.portal_urls = value&.split(/\s+/)
      end

      def query_term
        settings_query_term.present? ? settings_query_term : title
      end
    end
  end
end
