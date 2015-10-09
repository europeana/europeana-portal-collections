##
# Various ways of browsing the Europeana portal
class BrowseController < ApplicationController
  include Catalog
  include Europeana::Styleguide

  # GET /browse/colours
  def colours
    params = { query: '*:*', rows: 0, profile: 'minimal facets' }
    response = repository.search(params)
    @colours = response.aggregations['COLOURPALETTE'].items

    respond_to do |format|
      format.html
    end
  end

  # GET /browse/newcontent
  def new_content
    @providers = Rails.cache.fetch('browse/new_content/providers') || []

    respond_to do |format|
      format.html
    end
  end
end
