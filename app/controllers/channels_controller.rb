class ChannelsController < ApplicationController
  include Blacklight::Catalog
  include ChannelsBlacklightConfig
  include EuropeanaBlacklightAdapter
  
  helper_method :has_search_parameters?
  
  def show
    @channel = Channel.find(params[:id].to_sym)
    
    user_params = params.dup
    if channel_query = @channel.query
      user_params[:q] = user_params[:q] ? "(#{channel_query}) AND #{user_params[:q]}" : channel_query
    end
    
    (@response, @document_list) = get_search_results(user_params)
      
    respond_to do |format|
      format.html { render 'catalog/index' }
      format.rss  { render 'catalog/index', :layout => false }
      format.atom { render 'catalog/index', :layout => false }
      format.json do
        render json: render_search_results_as_json
      end

      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  # Channels always have search parameters, even if none are entered by the user
  # @see Blacklight::Catalog#has_search_parameters?
  def has_search_parameters?
    true
  end
  
  def _prefixes
    @_prefixes_with_partials ||= super | %w(catalog)
  end
  
  def search_action_url(options = {})
    url_for(options.merge(:action => 'show'))
  end
end
