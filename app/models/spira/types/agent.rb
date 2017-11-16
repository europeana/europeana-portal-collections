# frozen_string_literal: true

module Spira
  module Types
    class Agent < Any
      include Spira::Type

      def self.unserialize(value)
        value.is_a?(RDF::URI) ? Europeana::Record::Agent.for(value) : super
      end
    end
  end
end
