# frozen_string_literal: true

module EDM
  module Entity
    class Base
      include ActiveModel::Model

      attr_accessor :id

      class << self
        attr_reader :human_type

        def subclass_for_human_type(human_type)
          case human_type
            when 'period'
              EDM::Entity::Timespan
            when 'person'
              EDM::Entity::Agent
            when 'place'
              EDM::Entity::Place
            when 'topic'
              EDM::Entity::Concept
            else
              fail ArgumentError, %(Human entity type unknown: "#{human_type}")
          end
        end

        protected

        def has_human_type(human_type)
          @human_type = human_type
        end
      end
    end
  end
end