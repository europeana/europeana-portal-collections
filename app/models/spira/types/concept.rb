# frozen_string_literal: true

module Spira
  module Types
    class Concept < Any
      include Spira::Type

      def self.unserialize(value)
        value.is_a?(RDF::URI) ? Europeana::Record::Concept.for(value) : super
      end
    end
  end
end
