module EDM
  class Entity < Base
    def self.build(params)
      case params[:type]
        when 'people'
          Entity::Person.new(params[:id])
        when 'periods'
          Entity::Period.new(params[:id])
        when 'topics'
          Entity::Topic.new(params[:id])
        when 'places'
          Entity::Place.new(params[:id])
      end
    end

    def whoami
      raise 'The method `to_s` not implemented in entity sub-class'
    end
  end
end
