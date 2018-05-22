# frozen_string_literal: true

class GalleryImage
  module EuropeanaRecordAPI
    extend ActiveSupport::Concern

    include MayValidateMayNot

    included do
      may_validate_with :europeana_record_api

      before_validation if: :validating_with_europeana_record_api? do
        self.url ||= url_from_europeana_record_edm_is_shown_by
      end

      validate :validate_found_europeana_record_id, if: :validating_with_europeana_record_api?
      validate :validate_europeana_record_web_resource, if: :validating_with_europeana_record_api?
    end

    class_methods do
      def from_portal_url(portal_url)
        europeana_record_id = Europeana::Record.id_from_portal_url(portal_url)
        portal_url_query = Rack::Utils.parse_query(URI.parse(portal_url).query)
        url = portal_url_query.nil? || portal_url_query['view'].nil? ? nil : CGI.unescape(portal_url_query['view'])
        new(europeana_record_id: europeana_record_id, url: url)
      end

      def find_or_create_from_portal_url(portal_url, **options)
        tmp_image = from_portal_url(portal_url)
        options[:europeana_record_id] = tmp_image.europeana_record_id
        options[:url] = tmp_image.url
        find_or_create_by(options)
      end
    end

    # Europeana record for +europeana_record_id+
    #
    # @return [Europeana::Record]
    def europeana_record
      @europeana_record ||= Europeana::Record.new(europeana_record_id)
    end

    # RDF URI for +url+
    #
    # @return [RDF::URI]
    def rdf_uri
      RDF::URI.parse(url)
    end

    # Extracts the edm:isShownBy URL from the Europeana record, if present
    #
    # @return [String]
    def url_from_europeana_record_edm_is_shown_by
      europeana_record.edm_is_shown_by_uri&.to_s
    end

    # Validates that the +url+ is equivalent to one of the web resource URIs in
    # the Record API's response for
    def validate_europeana_record_web_resource
      unless rdf_uri == europeana_record.edm_is_shown_by_uri ||
             europeana_record.edm_has_view_uris.include?(rdf_uri)
        errors.add(:url, %(Record "#{europeana_record_id}" has no edm:isShownBy or edm:hasView with URI "#{url}"))
      end
    end

    # Validates that +europeana_record_id+ exists on the API.
    def validate_found_europeana_record_id
      if europeana_record.rdf.nil?
        errors.add(:europeana_record_id, %(Record not found by the API: "#{europeana_record_id}"))
      end
    end
  end
end
