# frozen_string_literal: true

module Europeana
  class Record
    class TimeSpan < Spira::Base
      type RDF::Vocab::EDM.TimeSpan

      property :dcterms_isPartOf, predicate: RDF::Vocab::DC.isPartOf, type: 'TimeSpan'

      property :edm_begin, predicate: RDF::Vocab::EDM.begin
      property :edm_end, predicate: RDF::Vocab::EDM.end

      property :skos_prefLabel, predicate: RDF::Vocab::SKOS.prefLabel, localized: true
    end
  end
end
