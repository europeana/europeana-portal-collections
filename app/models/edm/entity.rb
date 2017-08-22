module EDM
  class Entity
    include ActiveModel::Model

    attr_accessor :id

    class << self
      attr_reader :human_type

      def build_from_params(params)
        subclass_for_human_type(params.delete(:type).singularize).new(params)
      end

      def subclass_for_human_type(human_type)
        subclasses.detect { |subclass| subclass.human_type == human_type }.tap do |subclass|
          fail ArgumentError, %(Human entity type unknown: "#{human_type}") if subclass.nil?
        end
      end

      protected

      def has_human_type(human_type)
        @human_type = human_type
      end
    end
    #
    # class Agent < Entity
    #   has_human_type 'person'
    # end
    #
    # class Concept < Entity
    #   has_human_type 'topic'
    # end
    #
    # class Place < Entity
    #   has_human_type 'place'
    # end
    #
    # class Timespan < Entity
    #   has_human_type 'period'
    # end
  end
end