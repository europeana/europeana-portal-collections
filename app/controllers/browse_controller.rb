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
    @providers = Rails.cache.fetch('browse/new_content/providers') || []

    respond_to do |format|
      format.html
    end
  end

  # GET /browse/sources
  # @todo Load @providers from view helper, to bypass if HTML cached
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
