# frozen_string_literal: true
module Europeana
  ##
  # Methods for working with the Europeana Annotations API
  module AnnotationsApiConsumer
    extend ActiveSupport::Concern

    def document_annotations(document)
      search_response = annotations_search_for_document(document)
      return nil unless search_response.key?('items')

      annotations_from_search_response(search_response).
        map { |annotation| annotation_text_to_display(annotation) }.compact
    rescue Europeana::API::Errors::ServerError, Europeana::API::Errors::ResponseError => error
      # @todo we may not want controller actions to fail if annotations are
      #   unavailable, but we should return something indicating that there
      #   was a failure and perhaps indicate it to the user, e.g. as
      #   "Annotations could not be retrieved".
      logger.error(error.message)
      nil
    end

    def annotations_search_for_document(document)
      Europeana::API.annotation.search(annotations_api_search_params(document))
    end

    def annotations_from_search_response(search_response)
      if annotations_search_profile_minimal?(search_response)
        annotations_from_uris(search_response['items'])
      else
        search_response['items']
      end
    end

    def annotations_search_profile_minimal?(search_response)
      search_response['items'].any? { |item| item.is_a?(String) }
    end

    def annotations_from_uris(uris)
      Europeana::API.in_parallel do |queue|
        uris.each do |item|
          provider, id = item.split('/')[-2..-1]
          queue.add(:annotation, :fetch, annotations_api_fetch_params(provider, id))
        end
      end
    end

    def annotation_text_to_display(annotation)
      if annotation['body'].is_a?(String) && annotation['body'] =~ URI.regexp
        annotation['body']
      elsif annotation['body'] && annotation['body']['@graph']
        %w(sameAs isShownAt isShownBy).each do |graph_field|
          return annotation['body']['@graph'][graph_field] if annotation['body']['@graph'][graph_field]
        end
      end
    end

    def annotations_api_search_params(document)
      {
        qf: [
          %(generator_name:#{ENV['EUROPEANA_ANNOTATIONS_API_GENERATOR_NAME'] || 'Europeana.eu*'}),
          %(target_id:"http://data.europeana.eu/item#{document.id}")
        ],
        query: '*:*',
        pageSize: 100
      }.reverse_merge(annotations_api_env_params)
    end

    def annotations_api_fetch_params(provider, id)
      {
        provider: provider,
        id: id
      }.reverse_merge(annotations_api_env_params)
    end

    def annotations_api_env_params
      {
        wskey: ENV['EUROPEANA_ANNOTATIONS_API_KEY'] || Europeana::API.key,
        api_url: ENV['EUROPEANA_ANNOTATIONS_API_URL'] || Europeana::API.url,
      }
    end
  end
end
