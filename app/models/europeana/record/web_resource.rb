# frozen_string_literal: true

module Europeana
  class Record
    class WebResource < Spira::Base
      type RDF::Vocab::EDM.WebResource

      has_many :dc_description, predicate: RDF::Vocab::DC11.description, localized: true
      property :dc_rights, predicate: RDF::Vocab::DC11.rights

      property :edm_rights, predicate: RDF::Vocab::EDM.rights, type: 'URI'
    end
  end
end
