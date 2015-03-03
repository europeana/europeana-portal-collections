module Europeana
  ##
  # "Solr" respository hooked up to Europeana REST API via {RSolr::Europeana}
  class SolrRepository < Blacklight::SolrRepository
    def blacklight_solr
      rsolr_europeana_config = blacklight_solr_config.merge(
        api_key: Rails.application.secrets.europeana_api_key
      )
      @blacklight_solr ||= RSolr::Europeana.connect(rsolr_europeana_config)
    end

    def find(id, params = {})
      solr_response = super
      if solr_response.docs.first.present?
        solr_response.docs.first['hierarchy'] = fetch_document_hierarchy(id)
      end
      solr_response
    end

    def fetch_document_hierarchy(id)
      Rails.cache.fetch("europeana/hierarchy/#{id}") do
        begin
          record = Europeana::Record.new("/#{id}")
          hierarchy = record.hierarchy('ancestor-self-siblings')

          if hierarchy['self']['hasChildren']
            hierarchy = record.hierarchy('ancestor-self-siblings', :children)
          end

          hierarchy
        rescue Europeana::Errors::RequestError => error
          raise unless error.message == 'This record has no hierarchical structure!'
          false
        end
      end
    end

    def send_and_receive(path, solr_params = {})
      return super unless solr_params.present?
      Rails.cache.fetch(solr_params) do
        # Send the request to the API if result is not already cached
        super
      end
    end
  end
end
