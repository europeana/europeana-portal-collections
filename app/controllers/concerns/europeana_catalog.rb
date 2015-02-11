module EuropeanaCatalog
  extend ActiveSupport::Concern
  
  include Blacklight::Catalog
  include ChannelsBlacklightConfig
  
  included do
    # Adds Blacklight nav action for Channels
    add_nav_action(:channels, partial: 'channels/nav')
  end
  
  def search_facet_url options = {}
    url_for params.merge(controller: "catalog", action: "facet").merge(options).except(:page)
  end
  
  def solr_repository
    @solr_repository ||= Europeana::SolrRepository.new(blacklight_config)
  end
  
  def channels_search_params
    if @channels_search_params.nil?
      @channels_search_params = {}
      if current_search_session.query_params[:controller] == 'channels'
        if current_search_session.query_params[:id]
          channel = Channel.find(current_search_session.query_params[:id].to_sym)
          query_parts = []
          query_parts << "#{current_search_session.query_params[:q]}" if current_search_session.query_params[:q].present?
          query_parts << "(#{channel.query})" if channel.query.present?
          @channels_search_params[:q] = query_parts.join(' AND ')
        end
      end
    end
    @channels_search_params
  end
  
  # Identical to Blacklight::Catalog::SearchContext#setup_next_and_previous_documents
  # but with addition of channels_search_params to get_previous_and_next_documents_for_search
  # method call.
  def setup_next_and_previous_documents
    if search_session['counter'] and current_search_session
      index = search_session['counter'].to_i - 1
      response, documents = get_previous_and_next_documents_for_search index, current_search_session.query_params.with_indifferent_access, channels_search_params

      search_session['total'] = response.total
      @search_context_response = response
      @previous_document = documents.first
      @next_document = documents.last
    end
  end
end
