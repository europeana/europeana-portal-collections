# frozen_string_literal: true

class GalleryImage
  # TODO: does any of this belong in the API gem instead? e.g. +#europeana_record_rdf+
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
        url = portal_url_query.nil? ? nil : portal_url_query['view']
        new(europeana_record_id: europeana_record_id, url: url)
      end

      def find_or_create_from_portal_url(portal_url, **options)
        tmp_image = from_portal_url(portal_url)
        options.merge!(europeana_record_id: tmp_image.europeana_record_id, url: tmp_image.url)
        find_or_create_by(options)
      end
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
      europeana_record_rdf.query(predicate: RDF::Vocab::EDM.isShownBy).first&.object&.to_s
    end

    # RDF from which this image is derived.
    #
    # This is the full RDF graph response from the Record API for +europeana_record_id+
    #
    # @param force Force re-requesting the HTTP response.
    # @return [RDF::Graph] RDF graph for the Europeana record, or nil if not available.
    def europeana_record_rdf(force: false)
      return @europeana_record_rdf unless force || !instance_variable_defined?(:@europeana_record_rdf)

      begin
        @europeana_record_rdf = RDF::Graph.load(europeana_record_api_json_ld_uri)
      rescue StandardError
        @europeana_record_rdf = nil
      end

      @europeana_record_rdf
    end

    # URI to query the Record API for the record's JSON-LD
    #
    # @return [URI]
    #
    # TODO: does this need to observe +api_url+ overriden in the request parameters?
    # TODO: use API gem, updated for JSON-LD support?
    def europeana_record_api_json_ld_uri
      URI.parse(Europeana::API.url).tap do |uri|
        uri.path = "/api/v2/record#{europeana_record_id}.json-ld"
        uri.query = "wskey=#{Europeana::API.key}"
      end
    end

    # Web resource URIs from the Europeana record
    #
    # @return [Array<RDF::URI>]
    def europeana_record_web_resource_uris
      europeana_record_rdf&.query(predicate: RDF.type, object: RDF::Vocab::EDM.WebResource)&.map(&:subject)
    end

    # Validates that the +url+ is equivalent to one of the web resource URIs in
    # the Record API's response for 
    def validate_europeana_record_web_resource
      return if europeana_record_web_resource_uris.blank?
      unless europeana_record_web_resource_uris.include?(rdf_uri)
        errors.add(:url, %(Record "#{europeana_record_id}" has no web resource "#{url}"))
      end
    end

    # Validates that +europeana_record_id+ exists on the API.
    def validate_found_europeana_record_id
      if europeana_record_rdf.nil?
        errors.add(:europeana_record_id, %(Record not found by the API: "#{europeana_record_id}"))
      end
    end
  end
end
