# frozen_string_literal: true

module Europeana
  class Record
    class Place < Spira::Base
      type RDF::Vocab::EDM.Place

      property :geo_lat, predicate: RDF::Vocab::GEO.lat
      property :geo_long, predicate: RDF::Vocab::GEO.long
    end
  end
end
