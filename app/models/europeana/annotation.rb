# frozen_string_literal: true

module Europeana
  ##
  # Models annotations stored and exposed via the Europeana Annotations API
  #
  # @see https://pro.europeana.eu/resources/apis/annotations-api
  class Annotation
    include ActiveModel::Model

    attr_accessor :api_user_token, :body, :bodyValue, :created, :creator,
                  :generated, :generator, :id, :motivation, :target, :type

    class << self
      def find(**params)
        params[:profile] = 'standard'
        search_response = Europeana::API.annotation.search(self::API.search_params(params))
        return [] unless search_response.key?('items')
        search_response['items'].map { |hash| new(hash.except('@context')) }
      end

      def create(**params)
        new(params).save
      end
    end

    def save
      Europeana::API.annotation.create(
        self.class::API.create_params(
          body: body_params, user_token: api_user_token
        )
      )
    end

    def delete
      Europeana::API.annotation.delete(
        self.class::API.delete_params(
          id: id, user_token: api_user_token
        )
      )
    end

    def to_s
      if body_is_uri?
        body
      elsif body_has_graph?
        to_s_from_graph
      end
    end

    protected

    def body_params
      instance_values.symbolize_keys.except(:api_user_token)
    end

    def body_is_uri?
      body.is_a?(String) && body =~ URI::DEFAULT_PARSER.make_regexp
    end

    def body_has_graph?
      body.is_a?(Hash) && body['@graph'].present?
    end

    def to_s_from_graph
      %w(sameAs isShownAt isShownBy).each do |graph_field|
        return body['@graph'][graph_field] if body['@graph'][graph_field].present?
      end
      nil
    end
  end
end
