module Europeana
  ##
  # "Solr" respository hooked up to Europeana REST API via {RSolr::Europeana}
  class SolrRepository < Blacklight::SolrRepository
    ##
    # Connects to Europeana REST API through {RSolr::Europeana}
    #
    # @return [RSolr::Europeana::Client]
    def blacklight_solr
      rsolr_europeana_config = blacklight_solr_config.merge(
        api_key: Rails.application.secrets.europeana_api_key
      )
      @blacklight_solr ||= RSolr::Europeana.connect(rsolr_europeana_config)
    end

    ##
    # Finds a single Europeana record, with hierarchy data
    #
    # @return (see Blacklight::SolrRepository#find)
    # @param (see Blacklight::SolrRepository#find)
    def find(id, params = {})
      solr_response = super
      if solr_response.docs.first.present?
        solr_response.docs.first['hierarchy'] = fetch_document_hierarchy("/#{id}")
      end
      solr_response
    end

    ##
    # Executes a Europeana API query, caching the responses
    #
    # @return (see Blacklight::SolrRepository#send_and_receive)
    # @param (see Blacklight::SolrRepository#send_and_receive)
    def send_and_receive(path, solr_params = {})
      return super unless solr_params.present?
      Rails.cache.fetch(solr_params) do
        # Send the request to the API if result is not already cached
        super
      end
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
      Rails.cache.fetch("europeana/hierarchy#{id}") do
        begin
          europeana_api_document_hierarchy(id)
        rescue Europeana::Errors::RequestError => error
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
      record = Europeana::Record.new(id)
      hierarchy = record.hierarchy('ancestor-self-siblings')

      if hierarchy['self']['hasChildren']
        hierarchy = record.hierarchy('ancestor-self-siblings', :children)
      end

      hierarchy
    end
  end
end
