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

  # GET /browse/sources
  def sources
    @providers = Rails.cache.fetch('browse/sources/providers') || []
    @providers.each do |provider|
      provider[:url] = search_path(f: { 'PROVIDER' => [provider[:text]] })
      provider[:data_providers] = Rails.cache.fetch("browse/sources/providers/#{provider[:text]}") || []
      provider[:data_providers].each do |dp|
        dp[:url] = search_path(f: { 'DATA_PROVIDER' => [dp[:text]] })
      end
    end

    respond_to do |format|
      format.html
    end
  end
end
