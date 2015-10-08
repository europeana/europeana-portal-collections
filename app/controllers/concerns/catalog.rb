require 'net/http'

##
# Include this concern in a controller to give it Blacklight catalog features
# with extensions specific to Europeana.
#
# @todo Does any of this belong in {Europeana::Blacklight}?
module Catalog
  extend ActiveSupport::Concern

  include ::Blacklight::Base
  include Europeana::Blacklight::Catalog
  include BlacklightConfig
  include ActiveSupport::Benchmarkable

  def doc_id
    @doc_id ||= '/' + params[:id]
  end

  def more_like_this(document, field = nil, extra_controller_params = {})
    mlt_params = params.dup.slice(:page, :per_page)
    mlt_params.merge!(mlt: document.id, mltf: field)
    mlt_params.merge!(extra_controller_params)
    search_results(mlt_params, search_params_logic)
  end

  protected

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
end
