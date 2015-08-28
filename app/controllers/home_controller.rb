##
# Home page
class HomeController < ApplicationController
  include Catalog
  include Europeana::Styleguide
  include BlogFetcher
  include WithLandingPage

  before_action :count_all, only: :index
  before_action :fetch_blog_items, only: :index
  before_action :find_channel, only: :index
  before_action :find_landing_page, only: :index

  # GET /
  def index
    respond_to do |format|
      format.html
    end
  end

  protected

  def find_channel
    @channel = Channel.find_or_initialize_by(key: 'home')
  end
end
