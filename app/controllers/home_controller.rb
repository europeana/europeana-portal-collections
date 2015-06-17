##
# Home page
class HomeController < ApplicationController
  include Europeana::Catalog
  include Europeana::Styleguide
  include BlogFetcher

  before_filter :count_all, only: :index
  before_filter :fetch_blog_items, only: :index

  # GET /
  def index
    respond_to do |format|
      format.html { render 'templates/Search/Search-home' }
    end
  end
end
