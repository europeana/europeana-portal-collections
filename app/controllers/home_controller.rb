##
# Home page
class HomeController < ApplicationController
  include RecordCountsHelper

  # GET /
  def index
    @collection = find_collection
    @landing_page = find_landing_page
    @europeana_item_count = cached_record_count # populated by {Cache::RecordCountsJob}

    respond_to do |format|
      format.html
    end
  end

  protected

  def find_collection
    Collection.find_or_initialize_by(key: 'all').tap do |collection|
      authorize! :show, collection
    end
  end

  def find_landing_page
    Page::Landing.find_or_initialize_by(slug: '').tap do |landing_page|
      authorize! :show, landing_page
    end
  end
end
