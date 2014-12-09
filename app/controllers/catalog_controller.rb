class CatalogController < ApplicationController  
  include Blacklight::Catalog
  include ChannelsBlacklightConfig
  include EuropeanaBlacklightAdapter
  
  def channel
    channel_id = params[:id]
    
    if channel_query = Channels::Application.config.channels[channel_id.to_sym][:query]
      params[:q] = params[:q] ? "(#{channel_query}) AND #{params[:q]}" : channel_query
    end
    
    index
    render :action => 'index'
  end
end
