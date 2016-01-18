##
# Various ways of browsing the Europeana portal
class BrowseController < ApplicationController
  include Catalog
  include Europeana::Styleguide

  # GET /browse/colours
  # @todo Load @colours from view helper, to bypass if HTML cached
  def colours
    @colours = Rails.cache.fetch('browse/colours/facets') || []
    @collection = Collection.published.find_by_key(params[:theme])

    respond_to do |format|
      format.html
    end
  end

  # GET /browse/newcontent
  # @todo Load @providers from view helper, to bypass if HTML cached
  def new_content
    @collection = Collection.published.find_by_key(params[:theme])
    cache_key = @collection.nil? ? 'browse/new_content/providers' : "record/counts/collections/#{@collection.key}/recent-additions"
    @providers = Rails.cache.fetch(cache_key) || []

    respond_to do |format|
      format.html
    end
  end

  # GET /browse/sources
  # @todo Load @providers from view helper, to bypass if HTML cached
  def sources
    @collection = Collection.published.find_by_key(params[:theme])
    cache_key = @collection.nil? ? 'browse/sources/providers' : "browse/sources/providers/#{@collection.key}"
    @providers = Rails.cache.fetch(cache_key) || []

    @providers.each do |provider|
      provider[:url] = search_path(f: { 'PROVIDER' => [provider[:text]] })
      cache_key = 'browse/sources/providers'
      cache_key << ('/' + @collection.key) unless @collection.nil?
      cache_key << ('/' + provider[:text])
      provider[:data_providers] = Rails.cache.fetch(cache_key) || []
      provider[:data_providers].each do |dp|
        dp[:url] = search_path(f: { 'DATA_PROVIDER' => [dp[:text]] })
      end
    end

    respond_to do |format|
      format.html
    end
  end
end
