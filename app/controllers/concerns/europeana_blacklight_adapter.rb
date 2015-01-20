module EuropeanaBlacklightAdapter
  extend ActiveSupport::Concern
  
  def blacklight_solr
    @europeana_api ||= RSolr::Europeana.connect(blacklight_solr_config.merge(api_key: Rails.application.secrets.europeana_api_key))
  end
  
  def solr_doc_params(id = nil)
    id ||= [ params[:provider_id], params[:record_id] ].join('/')
    super(id)
  end
  
  def current_search_session
    if @current_search_session.nil?
      @current_search_session = super
      if @current_search_session.query_params[:controller] == 'channels'
        if @current_search_session.query_params[:id]
          channel = Channel.find(@current_search_session.query_params[:id].to_sym)
          query_parts = []
          query_parts << "(#{channel.query})" if channel.query.present?
          query_parts << "(#{@current_search_session.query_params[:q]})" if @current_search_session.query_params[:q].present?
          @current_search_session.query_params[:q] = query_parts.join(' AND ')
        end
      end
    end
    @current_search_session
  end
end
