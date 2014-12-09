module EuropeanaBlacklightAdapter
  extend ActiveSupport::Concern
  
  def blacklight_solr
    @europeana_api ||= RSolr::Europeana.connect(blacklight_solr_config.merge(api_key: Rails.application.secrets.europeana_api_key))
  end
  
  def solr_doc_params(id = nil)
    id ||= [ params[:provider_id], params[:record_id] ].join('/')
    super(id)
  end
end
