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

  # class Entity < Base
  #   def initialize(params)
  #     @id = params[:id]
  #   end
  #
  #   def whoami
  #     raise 'The method `whoami` not implemented in entity sub-class'
  #   end
  # end

  module Entities
    class Person
      def initialize(*args)
        @id = args[0][:id]
      end

      def whoami
        "I am a person entity with id=#{@id}"
      end
    end

    class Period
      def initialize(*args)
        @id = args[0][:id]
      end

      def whoami
        "I am a period entity with id=#{@id}"
      end
    end


    class Place
      def initialize(*args)
        @id = args[0][:id]
      end

      def whoami
        "I am a place entity with id=#{@id}"
      end
    end

    class Topic
      def initialize(*args)
        @id = args[0][:id]
      end

      def whoami
        "I am a topic entity with id=#{@id}"
      end
    end
  end
end