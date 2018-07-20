# frozen_string_literal: true

module Europeana
  class Record
    # Hierarchies support for records
    module Hierarchies
      class << self
        # Is the document the ancestor of other Europeana records?
        #
        # Criteria:
        # * dcterms:hasPart values are present
        # * More of the dcterms:hasPart values are URIs starting
        #   "http://data.europeana.eu/item/" than are not
        #
        # @param dcterms_has_part [Array<String>] dcterms:hasPart values to assess
        # @return [Boolean]
        def europeana_ancestor?(dcterms_has_part)
          return false unless dcterms_has_part.present?

          europeana_uri_count = dcterms_has_part.select { |hp| hp.to_s.start_with?('http://data.europeana.eu/item/') }.size
          other_uri_count = dcterms_has_part.size - europeana_uri_count
          europeana_uri_count > other_uri_count
        end
      end
    end
  end
end
