class CatalogController < ApplicationController  
  include EuropeanaCatalog

  def show
    # Fake ID param for Blacklight::Catalog#show
    params[:id] = [ params[:provider_id], params[:record_id] ].join('/')
    super
    params.delete(:id)
  end
end
