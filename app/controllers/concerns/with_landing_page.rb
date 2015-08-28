module WithLandingPage
  extend ActiveSupport::Concern

  def find_landing_page
    @landing_page = LandingPage.find_by_channel_id(@channel.id) || LandingPage.new
    @landing_page.hero_image || @landing_page.build_hero_image
    @landing_page.hero_image.media_object || @landing_page.hero_image.build_media_object
  end
end
