module EDM
  class Entity < Base
    def self.build(params)
      type = params.delete(:type)
      case type
        when 'people'
          Entities::Person.new(params)
        when 'periods'
          Entities::Period.new(params)
        when 'topics'
          Entities::Topic.new(params)
        when 'places'
          Entities::Place.new(params)
      end
    end
  end

  module Entities
    class Base
      attr_reader :id

      def initialize(params)
        @id = params[:id]
      end

      def entity_type
        self.class.name.sub('EDM::Entities::','').downcase
      end

      def whoami
        "I am a `#{entity_type}` entity with id=#{id}"
      end
    end

    class Person < Base
    end

    class Period < Base
    end

    class Place < Base
    end

    class Topic < Base
    end
  end
end