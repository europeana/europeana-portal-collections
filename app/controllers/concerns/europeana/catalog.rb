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
      before_filter :fix_model

      self.search_params_logic = [
        :default_api_parameters, :add_profile_to_api,
        :add_wskey_to_api, :add_query_to_api, :add_qf_to_api,
        :add_facet_qf_to_api, :add_facetting_to_api,
        :add_paging_to_api, :add_sorting_to_api
      ]
    end

    def fetch_one(id, _extra_controller_params)
      api_parameters = { wskey: Rails.application.secrets.europeana_api_key }
      api_response = repository.find(id, api_parameters)
      [api_response, api_response]
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

     def fix_model
    
      @pagetitle     = params['q']
      @searchresults = @document_list
      
      @head_meta = [
        #{'name':'X-UA-Compatible',    'content': 'IE=edge'},
        #{'name':'viewport',           'content': 'width=device-width,initial-scale=1.0'},        
        {'meta_name':'HandheldFriendly',   'content': 'True'},
        {'httpequiv':'Content-Type',       'content': 'text/html; charset=utf-8' },
        {'meta_name':'csrf-param',         'content': 'authenticity_token'},
        {'meta_name':'csrf-token',         'content': form_authenticity_token }
      ]

      @form_action_search = request.protocol + request.host_with_port + '/'
        
      @head_links = [
        {'rel':'search',        'type':'application/opensearchdescription+xml', 'href': request.host_with_port + '/catalog/opensearch.xml', 'title':'Blacklight'},
        {'rel':'shortcut icon', 'type':'image/x-icon',                          'href': 'assets/favicon.ico'},
        {'rel':'stylesheet',     'href':'/assets/blacklight.css',               'media':'all'},
        {'rel':'stylesheet',     'href':'/assets/europeana.css',                'media':'all'},
        {'rel':'stylesheet',     'href':'/assets/application.css',              'media':'all'}
      ]
      
      
      @input_search = {
        'title': 'Search',
        'input_name':  'q',
        'input_value': params['q'] ? params['q'] : '',
        'placeholder': 'Add a search term'
      }

      # All theses are blacklight's dependencies - getting the via the helper would be nicer    
      @js_files = [
        {'path': 'assets/jquery.js'},
        {'path': 'assets/turbolinks.js'},
        {'path': 'assets/blacklight/core.js'},
        {'path': 'assets/blacklight/autofocus.js'},
        {'path': 'assets/blacklight/checkbox_submit.js'},
        {'path': 'assets/blacklight/bookmark_toggle.js'},
        {'path': 'assets/blacklight/ajax_modal.js'},
        {'path': 'assets/blacklight/search_context.js'},
        {'path': 'assets/blacklight/collapsable.js'},
        
        {'path': 'assets/bootstrap/transition.js'},
        {'path': 'assets/bootstrap/collapse.js'},
        {'path': 'assets/bootstrap/dropdown.js'},
        {'path': 'assets/bootstrap/alert.js'},
        {'path': 'assets/bootstrap/modal.js'},
          
        {'path': 'assets/blacklight/blacklight.js'}
      ]
      
      
      @menus= {
          'actions': {
            'button-title':'Actions',
            'menu_id': 'dropdown-result-actions',
            'menu-title': 'Save to:',
            'items': [
              {
                'url':'http://europeana.eu',
                'text': 'First Item'
              },
              {
                'url':'http://europeana.eu',
                'text': 'Another Label'
              },
              {
                'url':'http://europeana.eu',
                'text': 'Label here'
              },
              {
                'url':'http://europeana.eu',
                'text': 'Fourth Item'
              },
              {
                'divider': true
              },
              {
                'url':'http://europeana.eu',
                'text': 'Another Label',
                'calltoaction': true
              },
              {
                'divider': true
              },
              {
                'url':'http://europeana.eu',
                'text': 'Another Label',
                'calltoaction': true
              }
            ]
          },
          'sort': {
            'button-title':'Relevance',
            'menu_id': 'dropdown-result-sort',
            'menu-title': 'Sort by:',
            'items': [
              {
                'text': 'Date',
                'url':'http://europeana.eu'
              },
              {
                'text': 'Alphabetical',
                'url':'http://europeana.eu'
              },
              {
                'text': 'Relevance',
                'url':'http://europeana.eu'
              },
              {
                'divider': true
              },
              {
                'url':'http://europeana.eu',
                'text': 'Another Label',
                'calltoaction': true
              },
              {
                'divider': true
              },
              {
                'text': 'Advanced Search',
                'url':'http://europeana.eu',
                'calltoaction': true
              }
            ]
          } 
        }
    end
  end
end
