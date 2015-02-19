##
# Include this concern in a controller to give it Blacklight catalog features
# with extensions specific to Europeana.
module EuropeanaCatalog
  extend ActiveSupport::Concern

  include Blacklight::Catalog
  include ChannelsBlacklightConfig

  included do
    # Adds Blacklight nav action for Channels
    add_nav_action(:channels, partial: 'channels/nav')

    helper_method :within_channel? if respond_to?(:helper_method)
  end

  def search_facet_url(options = {})
    facet_url_params = { controller: 'catalog', action: 'facet' }
    url_for params.merge(facet_url_params).merge(options).except(:page)
  end

  def solr_repository
    @solr_repository ||= Europeana::SolrRepository.new(blacklight_config)
  end

  def within_channel?(localized_params = params)
    localized_params['controller'] == 'channels' &&
      localized_params['id'].present?
  end

  ##
  # Returns the current channel being viewed by the user
  #
  # @return [Channel]
  def current_channel
    return nil unless within_channel?
    Channel.find(params[:id].to_sym)
  end

  ##
  # Returns the current channel the current search was performed in
  #
  # @return [Channel]
  def current_search_channel
    return nil unless current_search_session.query_params[:id]
    Channel.find(current_search_session.query_params[:id].to_sym)
  end

  ##
  # Looks up and returns any additional hidden query parameters used to restrict
  # results to the active channel.
  #
  # @return (see #lookup_channels_search_params)
  def channels_search_params
    @channels_search_params ||= lookup_channels_search_params
  end

  # @return [Hash]
  def lookup_channels_search_params
    channel = current_channel || current_search_channel
    if channel.nil?
      {}
    else
      user_query = current_search_session.query_params[:q]
      query_parts = []
      query_parts << user_query if user_query.present?
      query_parts << "(#{channel.query})" if channel.query.present?
      { q: query_parts.join(' AND ') }
    end
  end

  ##
  # Overriding
  # {Blacklight::Catalog::SearchContext#setup_next_and_previous_documents} to
  # add {channels_search_params} to
  # {get_previous_and_next_documents_for_search} method call.
  def setup_next_and_previous_documents
    return unless search_session['counter'] && current_search_session
    index = search_session['counter'].to_i - 1
    response, documents = get_previous_and_next_documents_for_search index, current_search_session.query_params.with_indifferent_access, channels_search_params

    search_session['total'] = response.total
    @search_context_response = response
    @previous_document = documents.first
    @next_document = documents.last
  end
end
