class ChannelsController < ApplicationController
  include Blacklight::Catalog
  include ChannelsBlacklightConfig
  include EuropeanaBlacklightAdapter
  
  helper_method :has_search_parameters?
  
  def index
    @channel = Channel.find(:home)
    
    (@response, @document_list) = get_search_results if has_search_parameters?
      
    respond_to do |format|
      format.html { render (has_search_parameters? ? 'search-results' : 'index') }
      format.rss  { render 'catalog/index', :layout => false }
      format.atom { render 'catalog/index', :layout => false }
      format.json do
        render json: render_search_results_as_json
      end

      additional_response_formats(format)
      document_export_formats(format)
    end
  end
  
  def show
    redirect_to action: :index and return if params[:id] == 'home'
    @channel = Channel.find(params[:id].to_sym)
    
    if has_search_parameters?
      user_params = params.dup
      if channel_query = @channel.query
        user_params[:q] = user_params[:q] ? "(#{channel_query}) AND #{user_params[:q]}" : channel_query
      end
      
      (@response, @document_list) = get_search_results(user_params)
    end
      
    respond_to do |format|
      format.html { render (has_search_parameters? ? 'search-results' : 'show') }
      format.rss  { render 'catalog/index', :layout => false }
      format.atom { render 'catalog/index', :layout => false }
      format.json do
        render json: render_search_results_as_json
      end

      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  # Channels may have a search query, even if none are entered by the user
  # @see Blacklight::Catalog#has_search_parameters?
#  def has_search_parameters?
#    (@channel.present? and @channel.query.present?) or super
#  end
  
  def _prefixes
    @_prefixes_with_partials ||= super | %w(catalog)
  end
  
  def search_action_url(options = {})
    url_for(options.merge(:action => params[:action]))
  end
end
