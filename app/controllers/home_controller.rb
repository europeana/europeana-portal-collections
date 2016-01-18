##
# Home page
class HomeController < ApplicationController
  include Catalog
  include Europeana::Styleguide

  # GET /
  def index
    @collection = find_collection
    @landing_page = find_landing_page
    @europeana_item_count = Rails.cache.fetch('record/counts/all') # populated by {Cache::RecordCountsJob}

    respond_to do |format|
      format.html
    end
  end

  protected

  def find_collection
    Collection.find_or_initialize_by(key: 'home').tap do |collection|
      authorize! :show, collection
    end
  end

  def find_landing_page
    Page::Landing.find_or_initialize_by(slug: '').tap do |landing_page|
      authorize! :show, landing_page
    end
  end
end
