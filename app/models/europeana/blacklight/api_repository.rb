module Europeana
  module Blacklight
    ##
    # Repository hooked up to Europeana REST API via europeana-api gem
    #
    # @see Europeana::API
    class ApiRepository < ::Blacklight::AbstractRepository
      ##
      # Finds a single Europeana record, with hierarchy data
      #
      # @return (see Blacklight::SolrRepository#find)
      # @param (see Blacklight::SolrRepository#find)
      def find(id, params = {})
        cache_key = { "Europeana::API::Record/#{id}#object" => params }
        res_object = Rails.cache.fetch(cache_key) do
          Europeana::API.record("/#{id}", params)['object']
        end
        doc = blacklight_config.document_model.new(res_object)
        doc.hierarchy = fetch_document_hierarchy("/#{id}")
        doc
      end

      def search(params = {})
        res = Rails.cache.fetch('Europeana::API::Search' => params) do
          Europeana::API.search(params)
        end

        blacklight_config.response_model.new(
          res, params, document_model: blacklight_config.document_model)
      end

      ##
      # Fetches the hierarchy data for a Europeana record
      #
      # If the hierarchy data for the requested record is cached, that will be
      # returned, otherwise it will be obtained from the Europeana REST API.
      #
      # @param id [String] Europeana record ID, with leading slash
      # @return [Hash] Record's hierarchy data, or false if it has none
      def fetch_document_hierarchy(id)
        Rails.cache.fetch("Europeana::API::Record/#{id}#hierarchy") do
          begin
            europeana_api_document_hierarchy(id)
          rescue Europeana::API::Errors::RequestError => error
            unless error.message == 'This record has no hierarchical structure!'
              raise
            end
            false
          end
        end
      end

      ##
      # Requests hierarchy data for a Europeana record from the REST API
      #
      # The return value will contain a combination of the responses from the
      # ancestor-self-siblings and children API endpoints.
      #
      # @param id [String] Europeana record ID, with leading slash
      # @return [Hash] Record's hierarchy data
      def europeana_api_document_hierarchy(id)
        record = Europeana::API::Record.new(id)
        hierarchy = record.hierarchy('ancestor-self-siblings')

        if hierarchy['self']['hasChildren']
          hierarchy = record.hierarchy('ancestor-self-siblings', :children)
        end

        hierarchy
      end
    end
  end
end
