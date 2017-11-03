# frozen_string_literal: true

module Europeana
  class Annotation
    include ActiveModel::Model

    attr_accessor :body, :bodyValue, :created, :creator, :generated, :generator,
                  :id, :motivation, :target, :type

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
      Europeana::API.annotation.create(self.class::API.create_params(instance_values))
    end

    def delete
      Europeana::API.annotation.delete(self.class::API.delete_params(id))
    end

    def to_s
      if body.is_a?(String) && body =~ URI::DEFAULT_PARSER.make_regexp
        body
      elsif body.is_a?(Hash) && body['@graph']
        %w(sameAs isShownAt isShownBy).each do |graph_field|
          return body['@graph'][graph_field] if body['@graph'][graph_field]
        end
      end
    end
  end
end
