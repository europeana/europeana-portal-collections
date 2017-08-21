module EDM
  class Entity < Base
    class << self
      attr_reader :type, :id
      def build_from_params(params)
        @type = params[:type]
        @id = params[:id]
        self
      end
    end
  end
end
