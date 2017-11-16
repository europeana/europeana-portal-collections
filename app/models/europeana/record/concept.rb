# frozen_string_literal: true

module Europeana
  class Record
    class Concept < Spira::Base
      type RDF::Vocab::SKOS.Concept

      has_many :skos_note, predicate: RDF::Vocab::SKOS.note, localized: true
      has_many :skos_prefLabel, predicate: RDF::Vocab::SKOS.prefLabel, localized: true
    end
  end
end
