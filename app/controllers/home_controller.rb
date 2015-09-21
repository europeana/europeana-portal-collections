##
# Home page
class HomeController < ApplicationController
  include Catalog
  include Europeana::Styleguide

  before_action :count_all, only: :index

  # GET /
  def index
    respond_to do |format|
      format.html
    end
  end
end
