class CatalogController < ApplicationController  
  include Blacklight::Catalog
  include ChannelsBlacklightConfig
  include EuropeanaBlacklightAdapter
  
  helper_method :available_channels
  
  def channel
    channel_id = params[:id]
    
    user_params = params.dup
    if channel_query = Channels::Application.config.channels[channel_id.to_sym][:query]
      user_params[:q] = user_params[:q] ? "(#{channel_query}) AND #{params[:q]}" : channel_query
    end
    
    (@response, @document_list) = get_search_results(user_params)
      
    respond_to do |format|
      format.html { render :action => 'index' }
      format.rss  { render :action => 'index', :layout => false }
      format.atom { render :action => 'index', :layout => false }
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
  
  def available_channels
    Channels::Application.config.channels.keys
  end
end
