##
# Various ways of browsing the Europeana portal
class BrowseController < ApplicationController
  include Catalog
  include Europeana::Styleguide

  # GET /browse/newcontent
  def new_content
    @providers = Rails.cache.fetch('browse/new_content/providers') || []

    respond_to do |format|
      format.html
    end
  end
end
