module Europeana
  module Blacklight
    ##
    # Core search builder for {Europeana::Blacklight::ApiRepository}
    class SearchBuilder < ::Blacklight::SearchBuilder
      require 'europeana/blacklight/search_builder/channels'
      require 'europeana/blacklight/search_builder/ranges'

      self.default_processor_chain = [
        :default_api_parameters, :add_profile_to_api,
        :add_wskey_to_api, :add_query_to_api, :add_qf_to_api,
        :add_facet_qf_to_api, :add_facetting_to_api,
        :add_paging_to_api, :add_sorting_to_api
      ]

      include Channels
      include Ranges

      ##
      # Start with general defaults from BL config. Need to use custom
      # merge to dup values, to avoid later mutating the original by mistake.
      #
      # @todo Rename default_solr_params to default_params upstream
      def default_api_parameters(api_parameters)
        blacklight_config.default_solr_params.each do |key, value|
          if value.respond_to?(:deep_dup)
            api_parameters[key] = value.deep_dup
          elsif value.respond_to?(:dup) && value.duplicable?
            api_parameters[key] = value.dup
          else
            api_parameters[key] = value
          end
        end
      end

      ##
      # Set the profile type
      #
      # @see http://labs.europeana.eu/api/search/#profile-parameter
      def add_profile_to_api(api_parameters)
        if blacklight_config.facet_fields
          api_parameters[:profile] = 'params facets rich'
        else
          api_parameters[:profile] = 'params rich'
        end
      end

      ##
      # Add the Europeana REST API key
      #
      # @see http://labs.europeana.eu/api/authentication/#basic-authentication
      def add_wskey_to_api(api_parameters)
        api_parameters[:wskey] = Rails.application.secrets.europeana_api_key
      end

      ##
      # Take the user-entered query, and put it in the API params,
      # including config's "search field" params for current search field.
      #
      # @see http://labs.europeana.eu/api/query/
      def add_query_to_api(api_parameters)
        if blacklight_params[:q].blank?
          api_parameters[:query] = '*:*'
        elsif search_field && search_field.field.present?
          api_parameters[:query] = "#{search_field.field}:#{blacklight_params[:q]}"
        elsif blacklight_params[:q].is_a?(Hash)
          # @todo when would it be a Hash?
        elsif blacklight_params[:q]
          api_parameters[:query] = blacklight_params[:q]
        end
      end

      ##
      # Add the user's query filter terms
      def add_qf_to_api(api_parameters)
        return unless blacklight_params[:qf]
        api_parameters[:qf] ||= []
        api_parameters[:qf] = api_parameters[:qf] + blacklight_params[:qf]
      end

      ##
      # Facet *filtering* of results
      #
      # Maps Blacklight's :f param to API's :qf param.
      #
      # @see http://labs.europeana.eu/api/query/#faceted-search
      # @todo Handle different types of value, like
      #   {Blacklight::Solr::SearchBuilder#facet_value_to_fq_string} does
      def add_facet_qf_to_api(api_parameters)
        return unless blacklight_params[:f]
        blacklight_params[:f].each_pair do |facet_field, value_list|
          Array(value_list).each do |value|
            next if value.blank? # skip empty strings
            # bizarrely, reusability is a distinct API param, even though it
            # is returned with the facets in a search response
            if facet_field == 'REUSABILITY'
              api_parameters[:reusability] = value
            else
              api_parameters[:qf] ||= []
              api_parameters[:qf] << "#{facet_field}:\"#{value}\""
            end
          end
        end
      end

      ##
      # Request facet data in results, respecting configured limits
      #
      # @todo Handle facet settings like query, sort, pivot, etc, like
      #  {Blacklight::Solr::SearchBuilder#add_facetting_to_solr} does
      # @see http://labs.europeana.eu/api/search/#individual-facets
      # @see http://labs.europeana.eu/api/search/#offset-and-limit-of-facets
      def add_facetting_to_api(api_parameters)
        api_request_facets = blacklight_config.facet_fields.select do |_field_name, facet|
          !facet.query && (facet.include_in_request || (facet.include_in_request.nil? && blacklight_config.add_facet_fields_to_solr_request))
        end

        api_parameters[:facet] = api_request_facets.keys.join(',')

        api_request_facets.each do |field_name, facet|
          api_parameters[:"f.#{facet.field}.facet.limit"] = (facet_limit_for(field_name) + 1) if facet_limit_for(field_name)
        end
      end

      ##
      # copy paging params from BL app over to API, changing
      # app level per_page and page to API rows and start.
      def add_paging_to_api(api_parameters)
        rows(api_parameters[:rows] || 10) if rows.nil?
        api_parameters[:rows] = rows

        if start != 0
          api_parameters[:start] = start
        end
      end

      ##
      # @todo Implement when the API supports sorting
      def add_sorting_to_api(_api_parameters)
        fail NotImplementedError, 'Europeana REST API does not support sorting' unless sort.blank?
      end

      ##
      # Europeana API start param counts from 1
      def start(start = nil)
        super_start = super
        super_start == self ? super_start : super_start + 1
      end

      protected

      # Look up facet limit for given facet_field. Will look at config, and
      # if config is 'true' will look up from Solr @response if available. If
      # no limit is avaialble, returns nil. Used from #add_facetting_to_solr
      # to supply f.fieldname.facet.limit values in solr request (no @response
      # available), and used in display (with @response available) to create
      # a facet paginator with the right limit.
      def facet_limit_for(facet_field)
        facet = blacklight_config.facet_fields[facet_field]
        return if facet.blank? || !facet.limit

        if facet.limit == true
          blacklight_config.default_facet_limit
        else
          facet.limit
        end
      end
    end
  end
end
