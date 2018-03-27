##
# Various ways of browsing/exploring the Europeana portal
class ExploreController < ApplicationController
  include EnforceDefaultFormat

  # @todo Load @colours from view helper, to bypass if HTML cached
  def colours
    find_collection
    cache_key = @collection.nil? ? 'browse/colours/facets' : "browse/colours/facets/#{@collection.key}"
    @colours = Rails.cache.fetch(cache_key) || []

    respond_to do |format|
      format.html
    end
  end

  def topics
    find_collection
    @topics = browse_entries(:topic)

    respond_to do |format|
      format.html
    end
  end

  def people
    find_collection
    @people = browse_entries(:person)

    respond_to do |format|
      format.html
    end
  end

  def periods
    find_collection
    @periods = browse_entries(:period)

    respond_to do |format|
      format.html
    end
  end

  # @todo Load @providers from view helper, to bypass if HTML cached
  def new_content
    find_collection
    cache_key = @collection.nil? ? 'browse/new_content/providers' : "record/counts/collections/#{@collection.key}/recent-additions"
    @providers = Rails.cache.fetch(cache_key) || []

    respond_to do |format|
      format.html
    end
  end

  # @todo Load @providers from view helper, to bypass if HTML cached
  def sources
    find_collection
    cache_key = @collection.nil? ? 'browse/sources/providers' : "browse/sources/providers/#{@collection.key}"
    @providers = Rails.cache.fetch(cache_key) || []

    @providers.each do |provider|
      provider_params = { f: { 'PROVIDER' => [provider[:text]] } }
      provider[:url] = @collection.nil? ? search_path(provider_params) : collection_path(@collection, provider_params)
      provider[:data_providers] = Rails.cache.fetch(data_providers_cache_key(provider[:text])) || []
      provider[:data_providers].each do |dp|
        dp_params = { f: { 'DATA_PROVIDER' => [dp[:text]] } }
        dp[:url] = @collection.nil? ? search_path(dp_params) : collection_path(@collection, dp_params)
      end
    end

    respond_to do |format|
      format.html
    end
  end

  protected

  # @param subject_type [Symbol] {BrowseEntry} `subject_type` attr
  def browse_entries(subject_type)
    query = BrowseEntry.includes(:translations).send(subject_type).published
    unless @collection.nil?
      query = query.joins(:collections).where('collections.id=?', @collection.id)
    end
    query.sort_by(&:title)
  end

  ##
  # Returns the cache key where data provider record counts for one provider are stored
  #
  # @param provider [String] provider name
  def data_providers_cache_key(provider)
    cache_key = 'browse/sources/providers'
    cache_key += ('/' + @collection.key) unless @collection.nil?
    cache_key += ('/' + provider)
  end

  def find_collection
    @collection ||= Collection.published.find_by_key(params[:theme])
  end
end
