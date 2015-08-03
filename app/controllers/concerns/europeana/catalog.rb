require 'net/http'

module Europeana
  ##
  # Include this concern in a controller to give it Blacklight catalog features
  # with extensions specific to Europeana.
  #
  # @todo Break up into sub-modules
  # @todo Does any of this belong in {Europeana::Blacklight}?
  module Catalog
    extend ActiveSupport::Concern

    include ::Blacklight::Base
    include BlacklightConfig
    include ::Blacklight::Catalog
    include ActiveSupport::Benchmarkable

    included do
      # Adds Blacklight nav action for Channels
      # @todo move to europeana-blacklight gem; not used by europeana-styleguide
      #   mustache templates
      # add_nav_action(:channels, partial: 'channels/nav')

      before_action :retrieve_response_and_document_list,
                    if: :has_search_parameters?

      self.search_params_logic = true
    end

    def has_search_parameters?
      super || params.key?(:q) || params.key?(:mlt)
    end

    def search_results(user_params, search_params_logic)
      super.tap do |results|
        if has_search_parameters?
          results.first[:facet_queries] = query_facet_counts(user_params)
        end
      end
    end

    # @todo Move to europeana-blacklight gem?
    def query_facet_counts(user_params)
      query_facets = blacklight_config.facet_fields.select do |_, facet|
        facet.query &&
          (facet.include_in_request ||
          (facet.include_in_request.nil? &&
          blacklight_config.add_facet_fields_to_solr_request))
      end

      query_facet_counts = []

      query_facets.each_pair do |_facet_name, query_facet|
        query_facet.query.each_pair do |_field_name, query_field|
          query = search_builder_class.new(search_params_logic, self).
            with(user_params).with_overlay_params(query_field[:fq] || {}).query.
            merge(rows: 0, start: 1, profile: 'minimal')
          query_facet_response = repository.search(query)
          query_facet_counts.push([query_field[:fq], query_facet_response.total])
        end
      end

      query_facet_counts.sort_by!(&:last).reverse!

      query_facet_counts.each_with_object({}) do |qf, hash|
        hash[qf.first] = qf.last
      end
    end

    def doc_id
      @doc_id ||= '/' + params[:id]
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

    def fetch_with_hierarchy(id = nil, extra_controller_params = {})
      response, _document = fetch(id, extra_controller_params)
      hierarchy = repository.fetch_document_hierarchy(id)
      response.documents.first.hierarchy = hierarchy
      [response, response.documents.first]
    end

    def more_like_this(document, field = nil, extra_controller_params = {})
      mlt_params = params.dup.slice(:page, :per_page)
      mlt_params.merge!(mlt: document.id, mltf: field)
      mlt_params.merge!(extra_controller_params)
      search_results(mlt_params, search_params_logic)
    end

    def media_mime_type(document)
      edm_is_shown_by = document.fetch('aggregations.edmIsShownBy', []).first
      return nil if edm_is_shown_by.nil?

      cache_key = "Europeana/MediaProxy/#{edm_is_shown_by}"
      mime_type = Rails.cache.fetch(cache_key)
      if mime_type.nil?
        mime_type = remote_content_type_header(document)
        Rails.cache.write(cache_key, mime_type) unless mime_type.nil?
      end

      mime_type
    end

    protected

    def remote_content_type_header(document)
      url = URI(ENV['EDM_IS_SHOWN_BY_PROXY'] + document.id)
      benchmark("[Media Proxy] #{url}", level: :info) do
        Net::HTTP.start(url.host, url.port) do |http|
          response = http.head(url.path)
          response['content-type']
        end
      end
    end

    def search_action_url(options = {})
      case
      when options[:controller]
        url_for(options)
      when params[:controller] == 'channels'
        url_for(options.merge(controller: 'channels', action: params[:action]))
      else
        search_url(options.except(:controller, :action))
      end
    end

    def search_facet_url(options = {})
      facet_url_params = { controller: 'portal', action: 'facet' }
      url_for params.merge(facet_url_params).merge(options).except(:page)
    end

    def retrieve_response_and_document_list
      (@response, @document_list) = search_results(params, search_params_logic)
    end

    ##
    # Gets the total number of items available over the Europeana API
    #
    # @return [Fixnum]
    def count_all
      all_params = { query: '*:*', rows: 0, profile: 'minimal' }
      @europeana_item_count = repository.search(all_params).total
    end
  end
end
