class HeroImage < ActiveRecord::Base
  include HasSettingsAttribute

  has_settings(:attribution_title, :attribution_creator, :attribution_institution,
               :attribution_url, :attribution_text, :brand_opacity, :brand_position,
               :brand_colour, :ripple_width)

  has_one :page, inverse_of: :hero_image

  belongs_to :media_object, dependent: :destroy
  accepts_nested_attributes_for :media_object, allow_destroy: true

  delegate :settings_brand_opacity_enum, :settings_brand_position_enum,
           :settings_brand_colour_enum, :settings_ripple_width_enum, to: :class

  delegate :file, to: :media_object, allow_nil: true

  after_save :touch_page
  after_touch :touch_page

  has_paper_trail

  class << self
    def license_enum
      %w(public CC0 CC_BY CC_BY_SA CC_BY_ND CC_BY_NC CC_BY_NC_SA CC_BY_NC_ND RS_INC_EDU RS_NOC_OKLR RS_INC RS_NOC_NC RS_INC_OW_EU RS_CNE)
    end

    def settings_brand_opacity_enum
      [25, 50, 75, 100]
    end

    def settings_brand_position_enum
      %w(topleft topright bottomleft bottomright)
    end

    def settings_brand_colour_enum
      %w(site white black)
    end

    def settings_ripple_width_enum
      %w(thin medium thick)
    end
  end

  def file=(*args)
    (media_object || build_media_object).send(:file=, *args)
  end

  validates :license, inclusion: { in: license_enum }, allow_nil: true

  def touch_page
    page.touch if page.present?
  end
end
