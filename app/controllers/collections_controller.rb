# frozen_string_literal: true

##
# Provides Blacklight search and browse, within a content Collection
class CollectionsController < ApplicationController
  include Europeana::Collections
  include RecordCountsHelper
  include SearchInteractionLogging

  before_action :redirect_to_home, only: :show, if: proc { params[:id] == 'all' }

  def index
    respond_to do |format|
      format.html { redirect_to_home }
      format.rss { render 'collections/index', layout: false }
    end
  end

  def show
    @collection = find_collection
    @landing_page = find_landing_page

    if has_search_parameters?
      (@response, @document_list) = search_results(search_params)
      log_search_interaction_on_search(@response)
    else
      @collection_stats = collection_stats
      @recent_additions = recent_additions
      @total_item_count = cached_record_count(collection: @collection)
    end

    respond_to do |format|
      format.html do
        render has_search_parameters? ? { template: 'portal/index' } : { action: 'show' }
      end
      format.json do
        fail ActionController::UnknownFormat unless has_search_parameters?
        render template: 'portal/index', layout: false
      end
    end
  end

  def ugc
    @collection = find_collection
    fail ActiveRecord::RecordNotFound unless @collection.accepts_ugc?
  end

  protected

  def search_params
    params.dup.tap do |p|
      if p[:f].present? && p[:f][:api] == ['collection']
        p[:api_url] = @collection.api_url unless @collection.api_url.blank?
      end
    end
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
