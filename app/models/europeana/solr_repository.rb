module Europeana
  class SolrRepository < Blacklight::SolrRepository
    def blacklight_solr
      @blacklight_solr ||= RSolr::Europeana.connect(blacklight_solr_config.merge(api_key: Rails.application.secrets.europeana_api_key))
    end
  end
end
