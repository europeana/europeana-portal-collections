# frozen_string_literal: true

module Europeana
  class Record
    class Aggregation < Spira::Base
      type RDF::Vocab::ORE.Aggregation
      type RDF::Vocab::EDM.EuropeanaAggregation

      property :edm_aggregatedCHO, predicate: RDF::Vocab::EDM.aggregatedCHO, type: 'ProvidedCHO'
      property :edm_collectionName, predicate: RDF::Vocab::EDM.collectionName
      property :edm_country, predicate: RDF::Vocab::EDM.country
      property :edm_dataProvider, predicate: RDF::Vocab::EDM.dataProvider
      has_many :edm_hasViews, predicate: RDF::Vocab::EDM.hasView, type: 'WebResource'
      property :edm_isShownAt, predicate: RDF::Vocab::EDM.isShownAt
      property :edm_language, predicate: RDF::Vocab::EDM.language
      property :edm_isShownBy, predicate: RDF::Vocab::EDM.isShownBy, type: 'WebResource'
      property :edm_object, predicate: RDF::Vocab::EDM.object
      property :edm_provider, predicate: RDF::Vocab::EDM.provider
      property :edm_rights, predicate: RDF::Vocab::EDM.rights
    end
  end
end
