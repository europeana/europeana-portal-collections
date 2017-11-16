# frozen_string_literal: true

module Europeana
  class Record
    class Proxy < Spira::Base
      type RDF::Vocab::ORE.Proxy

      property :dc_coverage, predicate: RDF::Vocab::DC11.coverage
      has_many :dc_creator, predicate: RDF::Vocab::DC11.creator, type: Spira::Types::Agent
      property :dc_date, predicate: RDF::Vocab::DC11.date
      property :dc_description, predicate: RDF::Vocab::DC11.description, localized: true
      property :dc_format, predicate: RDF::Vocab::DC11.format
      property :dc_identifier, predicate: RDF::Vocab::DC11.identifier
      property :dc_language, predicate: RDF::Vocab::DC11.language
      property :dc_publisher, predicate: RDF::Vocab::DC11.publisher
      property :dc_rights, predicate: RDF::Vocab::DC11.rights
      has_many :dc_subject, predicate: RDF::Vocab::DC11.subject, type: Spira::Types::Agent
      property :dc_title, predicate: RDF::Vocab::DC11.title, localized: true
      has_many :dc_type, predicate: RDF::Vocab::DC11.type, type: Spira::Types::Concept

      property :dcterms_extent, predicate: RDF::Vocab::DC.extent
      property :dcterms_issued, predicate: RDF::Vocab::DC.issued
      property :dcterms_spatial, predicate: RDF::Vocab::DC.spatial, type: Spira::Types::Place

      property :edm_europeanaProxy, predicate: RDF::Vocab::EDM.europeanaProxy
      property :edm_type, predicate: RDF::Vocab::EDM.type

      property :ore_proxyFor, predicate: RDF::Vocab::ORE.proxyFor, type: 'ProvidedCHO'
      property :ore_proxyIn, predicate: RDF::Vocab::ORE.proxyIn, type: 'Aggregation'
    end
  end
end
