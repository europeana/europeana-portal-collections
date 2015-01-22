class ChannelsController < ApplicationController
  include EuropeanaCatalog
  
  def index
    @channel = Channel.find(:home)
    show
  end
  
  def show
    redirect_to action: :index and return if params[:id] == 'home'
    @channel ||= Channel.find(params[:id].to_sym)
    
    if has_search_parameters?
      (@response, @document_list) = get_search_results(params.merge(channels_search_params))
      html_template = 'search-results'
      @extra_body_classes = ['blacklight-' + controller_name, 'blacklight-' + controller_name + '-search']
    else
      html_template = (@channel.id == :home) ? 'index' : 'show'
    end
    
    respond_to do |format|
      format.html { render html_template }
      format.rss  { render 'catalog/index', :layout => false }
      format.atom { render 'catalog/index', :layout => false }
      format.json do
        render json: render_search_results_as_json
      end

      additional_response_formats(format)
      document_export_formats(format)
    end
  end
  
  def _prefixes
    @_prefixes_with_partials ||= super | %w(catalog)
  end
  
  def search_action_url(options = {})
    url_for(options.merge(:action => params[:action]))
  end
  
  def start_new_search_session?
    [ "index", "show" ].include?(action_name)
  end
end
