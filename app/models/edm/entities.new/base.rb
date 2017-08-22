module EDM
  module Entities
    module Base
      attr_reader :id, :type

      def initialize(params)
        @id = params[:id]
        @type = params[:type]
      end

      def whoami
        "I am a `#{type}` entity with id=#{id}"
      end
    end
  end
end