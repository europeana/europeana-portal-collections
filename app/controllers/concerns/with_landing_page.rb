module WithLandingPage
  extend ActiveSupport::Concern

  def find_landing_page
    @landing_page = LandingPage.published.find_by_channel_id(@channel.id) || LandingPage.new
  end
end
