##
# Include this concern in a controller to give it Blacklight catalog features
# with extensions specific to Europeana.
module EuropeanaCatalog
  extend ActiveSupport::Concern

  include Blacklight::Catalog
  include ChannelsBlacklightConfig
  include ChannelsHelper

  included do
    # Adds Blacklight nav action for Channels
    add_nav_action(:channels, partial: 'channels/nav')

    before_filter :retrieve_response_and_document_list,
              if: :has_search_parameters?
    before_filter :fix_model
  end

  def solr_repository
    @solr_repository ||= Europeana::SolrRepository.new(blacklight_config)
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
    return @channels_search_params if @channels_search_params.present?

    channel = current_channel || current_search_channel

    qfs = []
    qfs.push(channel.query) unless channel.nil? || channel.query.blank?
    qfs = qfs + params[:qf] unless params[:qf].blank?

    @channels_search_params = { qf: qfs }
  end

  ##
  # Overriding
  # {Blacklight::Catalog::SearchContext#setup_next_and_previous_documents} to
  # add {channels_search_params} to
  # {get_previous_and_next_documents_for_search} method call.
  def setup_next_and_previous_documents
    return unless search_session['counter'] && current_search_session
    index = search_session['counter'].to_i - 1
    response, documents = get_previous_and_next_documents_for_search(
      index, current_search_session.query_params.with_indifferent_access,
      channels_search_params
    )

    search_session['total'] = response.total
    @search_context_response = response
    @previous_document = documents.first
    @next_document = documents.last
  end

  def doc_id
    @doc_id ||= [params[:provider_id], params[:record_id]].join('/')
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

  def query_solr(user_params = params || {}, extra_controller_params = {})
    solr_params = solr_search_params(user_params)
    solr_params.merge!(extra_controller_params)
    solr_response = solr_repository.search(solr_params)
    emulate_query_faceting(solr_params, solr_response)
  end

  def emulate_query_faceting(solr_params, solr_response)
    return solr_response unless solr_params.key?('facet.query')

    query_facet_counts = count_query_facets(solr_params)

    solr_facet_queries = query_facet_counts.each_with_object({}) do |qf, hash|
      hash[qf.first] = qf.last
    end

    solr_response['facet_counts']['facet_queries'] = solr_facet_queries

    solr_response
  end

  def count_query_facets(solr_params)
    query_facet_counts = []

    solr_params['facet.query'].each do |query_facet_query|
      query_facet_params = solr_params.dup
      query_facet_params[:qf] ||= []
      query_facet_params[:qf] = query_facet_params[:qf] + [query_facet_query]
      query_facet_params.merge!(rows: 0, start: 0)
      query_facet_response = solr_repository.search(query_facet_params)
      query_facet_num_found = query_facet_response['response']['numFound']
      query_facet_counts.push([query_facet_query, query_facet_num_found])
    end

    query_facet_counts.sort_by(&:last).reverse
  end

  
  def retrieve_response_and_document_list
    search_results = get_search_results(params, channels_search_params)
    (@response, @document_list) = search_results
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
