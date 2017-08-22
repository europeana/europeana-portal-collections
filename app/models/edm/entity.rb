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

      def whoami
        raise 'Method `whoami` must be overriden in entity sub-class'
      end
    end

    class Person < Base
      def whoami
        "I am a person entity with id=#{id}"
      end
    end

    class Period
      def whoami
        "I am a period entity with id=#{@id}"
      end
    end

    class Place
      def whoami
        "I am a place entity with id=#{@id}"
      end
    end

    class Topic
      def whoami
        "I am a topic entity with id=#{@id}"
      end
    end
  end
end