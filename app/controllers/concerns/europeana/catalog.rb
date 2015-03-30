module Europeana
  ##
  # Include this concern in a controller to give it Blacklight catalog features
  # with extensions specific to Europeana.
  #
  # @todo Break up into sub-modules
  module Catalog
    extend ActiveSupport::Concern

    include ::Blacklight::Catalog
    include BlacklightConfig
    include ChannelsHelper

    included do
      # Adds Blacklight nav action for Channels
      add_nav_action(:channels, partial: 'channels/nav')

      before_filter :retrieve_response_and_document_list,
                    if: :has_search_parameters?

      self.search_params_logic = true
    end

    def fetch_one(id, _extra_controller_params)
      api_parameters = { wskey: Rails.application.secrets.europeana_api_key }
      api_response = repository.find(id, api_parameters)
      [api_response, api_response]
    end

    def search_results(user_params, search_params_logic)
      super.tap do |results|
        results.first[:facet_queries] = query_facet_counts(user_params)
      end
    end

    def query_facet_counts(user_params)
      # Ensure channels specific processors do not get triggered
      qf_search_params_logic = Europeana::Blacklight::SearchBuilder.default_processor_chain

      query_facets = blacklight_config.facet_fields.select do |_, facet|
        facet.query &&
        (facet.include_in_request ||
        (facet.include_in_request.nil? &&
        blacklight_config.add_facet_fields_to_solr_request))
      end

      query_facet_counts = []

      query_facets.each_pair do |_facet_name, query_facet|
        query_facet.query.each_pair do |_field_name, query_field|
          query_facet_params = user_params.dup
          query_facet_params[:qf] ||= []
          query_facet_params[:qf] << query_field[:fq]

          query = search_builder(qf_search_params_logic).with(query_facet_params).query.merge(rows: 0, start: 1, profile: 'minimal')
          query_facet_response = repository.search(query)

          query_facet_counts.push([query_field[:fq], query_facet_response.total])
        end
      end

      query_facet_counts.sort_by!(&:last).reverse!

      query_facet_counts.each_with_object({}) do |qf, hash|
        hash[qf.first] = qf.last
      end
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
    # Looks up and returns any additional hidden query parameters used to
    # restrict results to the active channel.
    #
    # @return [String]
    def channels_search_query
      channel = current_channel || current_search_channel
      channel.nil? ? nil : channel.query
    end

    def doc_id
      @doc_id ||= [params[:provider_id], params[:record_id]].join('/')
    end

    def previous_and_next_document_params(index, window = 1)
      api_params = {}

      if index > 1
        api_params[:start] = index - window # get one before
        api_params[:rows] = 2 * window + 1 # and one after
      else
        api_params[:start] = 1 # there is no previous doc
        api_params[:rows] = 2 * window # but there should be one after
      end

      api_params
    end

    def has_search_parameters?
      super || (params[:controller] == 'channels' && params.key?(:q))
    end

    protected

    def search_action_url(options = {})
      case
      when options[:controller]
        url_for(options)
      when params[:controller] == 'channels'
        url_for(options.merge(controller: 'channels', action: params[:action]))
      else
        super
      end
    end

    def search_facet_url(options = {})
      facet_url_params = { controller: 'catalog', action: 'facet' }
      url_for params.merge(facet_url_params).merge(options).except(:page)
    end

    def retrieve_response_and_document_list
      (@response, @document_list) = search_results(params, search_params_logic)
    end
  end
end
