##
# Home page
class HomeController < ApplicationController
  include Catalog
  include Europeana::Styleguide
  include BlogFetcher

  before_action :find_channel, only: :index
  before_action :find_landing_page, only: :index
  before_action :count_all, only: :index
  before_action :fetch_blog_items, only: :index

  # GET /
  def index
    respond_to do |format|
      format.html
    end
  end

  protected

  def find_channel
    @channel = Channel.find_or_initialize_by(key: 'home')
    authorize! :show, @channel
  end

  def find_landing_page
    @landing_page = Page::Landing.find_or_initialize_by(slug: '')
    authorize! :show, @landing_page
  end
end
