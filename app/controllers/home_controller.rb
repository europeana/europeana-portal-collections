##
# Home page
class HomeController < ApplicationController
  include Catalog
  include Europeana::Styleguide

  # GET /
  def index
    @europeana_item_count = Rails.cache.fetch('record/counts/all') # populated by {RecordCountsCacheJob}

    respond_to do |format|
      format.html
    end
  end
end
