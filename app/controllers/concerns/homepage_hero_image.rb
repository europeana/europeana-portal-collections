# frozen_string_literal: true

module HomepageHeroImage
  include ActiveSupport::Concern

  def homepage_hero_image
    homepage = Page::Landing.home
    homepage.nil? ? nil : homepage.hero_image
  end
end
