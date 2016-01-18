##
# Provides Blacklight search and browse, within a content Collection
class CollectionsController < ApplicationController
  include Catalog
  include Europeana::Collections
  include Europeana::Styleguide

  before_action :redirect_to_root, only: :show, if: proc { params[:id] == 'home' }

  def index
    redirect_to_root
  end

  def show
    @collection = find_collection
    @landing_page = find_landing_page
    @collection_stats = collection_stats
    @recent_additions = recent_additions

    (@response, @document_list) = search_results(params, search_params_logic) if has_search_parameters?

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
    # ['EDM value', 'i18n key']
    types = [['IMAGE', 'images'], ['TEXT', 'texts'], ['VIDEO', 'moving-images'],
             ['3D', '3d'], ['SOUND', 'sound']]
    collection_stats = types.map do |type|
      type_count = Rails.cache.fetch("record/counts/collections/#{@collection.key}/type/#{type[0].downcase}")
      {
        count: type_count,
        text: t(type[1], scope: 'site.collections.data-types'),
        url: collection_path(q: "TYPE:#{type[0]}")
      }
    end
    collection_stats.reject! { |stats| stats[:count] == 0 }
    collection_stats.sort_by { |stats| stats[:count] }.reverse
  end

  def recent_additions
    Rails.cache.fetch("record/counts/collections/#{@collection.key}/recent-additions") || []
  end
end
