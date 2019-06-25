# frozen_string_literal: true

module EDM
  module Entity
    class << self
      def build_from_params(params)
        self::Base.subclass_for_human_type(params.delete(:type).singularize).new(params)
      end

      def api_url
        @api_url ||= Rails.application.config.x.europeana[:entities].api_url || Europeana::API.url
      end

      def api_key
        @api_key ||= Rails.application.config.x.europeana[:entities].api_key
      end
    end
  end
end
