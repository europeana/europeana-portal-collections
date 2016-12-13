##
# Provides Blacklight search and browse, within a content Collection
class CollectionsController < ApplicationController
  include Europeana::Collections
  include RecordCountsHelper
  include SearchInteractionLogging

  before_action :redirect_to_home, only: :show, if: proc { params[:id] == 'all' }

  def index
    redirect_to_home
  end

  def show
    @collection = find_collection
    @landing_page = find_landing_page
    @collection_stats = collection_stats
    @recent_additions = recent_additions
    @total_item_count = Rails.cache.fetch("record/counts/collections/#{@collection.key}")

    if has_search_parameters?
      (@response, @document_list) = search_results(params)
      log_search_interaction(
        search: params.slice(:q, :f, :mlt, :range).inspect,
        total: @response.total
      )
    end

    respond_to do |format|
      format.html do
        render has_search_parameters? ? { template: '/portal/index' } : { action: 'show' }
      end
      format.rss { render 'catalog/index', layout: false }
      format.atom { render 'catalog/index', layout: false }
      format.json { render json: render_search_results_as_json }

      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  def tumblr
    @collection = find_collection
    respond_to do |format|
      format.json { render json: collection_tumblr_feed_content(@collection, params.slice(:page, :per_page)) }
    end
  end

  protected

  def _prefixes
    @_prefixes_with_partials ||= super | %w(catalog)
  end

  def start_new_search_session?
    has_search_parameters?
  end

  def find_collection
    Collection.find_by_key!(params[:id]).tap do |collection|
      authorize! :show, collection
    end
  end

  def find_landing_page
    Page::Landing.find_or_initialize_by(slug: "collections/#{@collection.key}").tap do |landing_page|
      authorize! :show, landing_page
    end
  end

  ##
  # Gets from the cache the number of items of each media type within the current collection
  def collection_stats
    collection_stats = EDM::Type.registry.map do |type|
      {
        count: cached_record_count(collection: @collection, type: type),
        text: type.label,
        url: collection_path(q: "TYPE:#{type.id}")
      }
    end
    collection_stats.reject! { |stats| stats[:count] == 0 }
    collection_stats.sort_by { |stats| stats[:count] }.reverse
  end

  def recent_additions
    Rails.cache.fetch("record/counts/collections/#{@collection.key}/recent-additions") || []
  end
end
