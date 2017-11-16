# frozen_string_literal: true

require 'rdf/vocab/rdagr2'

module Europeana
  class Record
    class Agent < Spira::Base
      type RDF::Vocab::EDM.Agent

      property :edm_begin, predicate: RDF::Vocab::EDM.begin
      property :edm_end, predicate: RDF::Vocab::EDM.end

      property :foaf_name, predicate: RDF::Vocab::FOAF.name

      property :rdagr2_biographicalInformation, predicate: RDF::Vocab::RDAGR2.biographicalInformation, localized: true
      property :rdagr2_dateOfBirth, predicate: RDF::Vocab::RDAGR2.dateOfBirth
      property :rdagr2_dateOfDeath, predicate: RDF::Vocab::RDAGR2.dateOfDeath
      property :rdagr2_placeOfBirth, predicate: RDF::Vocab::RDAGR2.placeOfBirth, type: 'URI'
      property :rdagr2_placeOfDeath, predicate: RDF::Vocab::RDAGR2.placeOfDeath, type: 'URI'
      property :rdagr2_professionOrOccupation, predicate: RDF::Vocab::RDAGR2.professionOrOccupation, type: 'URI'

      property :skos_altLabel, predicate: RDF::Vocab::SKOS.prefLabel, localized: true
      property :skos_prefLabel, predicate: RDF::Vocab::SKOS.altLabel, localized: true
    end
  end
end
