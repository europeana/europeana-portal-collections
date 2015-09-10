class LandingPagesController < ApplicationController
  def show
    landing_page = LandingPage.find_by_id!(params[:id])
    redirect_to url_for(landing_page.channel)
  end
end
