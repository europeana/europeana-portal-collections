# frozen_string_literal: true
module Europeana
  ##
  # Methods for working with the Europeana Annotations API
  module AnnotationsApiConsumer
    extend ActiveSupport::Concern

    def document_annotations(document)
      Europeana::API.annotation.search(annotations_api_search_params(document)).fetch('items', []).map do |anno|
        provider = anno.split('/')[-2]
        id = anno.split('/')[-1]
        Europeana::API.annotation.fetch(annotations_api_fetch_params(provider, id))['body']['@graph']['sameAs']
      end
    end

    def annotations_api_search_params(document)
      {
        qf: [
          %(generator_name:"#{ENV['EUROPEANA_ANNOTATIONS_API_GENERATOR_NAME'] || 'Europeana.eu'}"),
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
