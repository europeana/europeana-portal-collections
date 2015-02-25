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
  end
end
