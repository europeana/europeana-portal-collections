##
# Home page
class HomeController < ApplicationController
  include Europeana::Styleguide

  # GET /
  def index
    respond_to do |format|
      format.html { render 'templates/Search/Search-home' }
    end
  end
end
