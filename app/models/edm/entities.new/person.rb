module EDM
  module Entities
    include Entities::Base
    attr_reader :id, :type

    def initialize(params)
      @id = params[:id]
      @type = params[:type]
    end

    class Person
    end
  end
end