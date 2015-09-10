module WithLandingPage
  extend ActiveSupport::Concern

  def find_landing_page
    @landing_page = @channel.landing_page || LandingPage.new
    authorize! :show, @landing_page
  end
end
