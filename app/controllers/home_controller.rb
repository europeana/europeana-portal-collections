##
# Home page
class HomeController < ApplicationController
  include Europeana::Catalog
  include Europeana::Styleguide
  include BlogFetcher

  before_action :count_all, only: :index
  before_action :fetch_blog_items, only: :index

  # GET /
  def index
    respond_to do |format|
      format.html
    end
  end
end
