# frozen_string_literal: true

module EDM
  module Entity
    class << self
      def build_from_params(params)
        self::Base.subclass_for_human_type(params.delete(:type).singularize).new(params)
      end
    end
  end
end
