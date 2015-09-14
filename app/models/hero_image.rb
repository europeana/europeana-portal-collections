class HeroImage < ActiveRecord::Base
  include HasSettingsAttribute

  has_settings(:attribution_title, :attribution_creator, :attribution_institution,
               :attribution_url, :attribution_text, :brand_opacity, :brand_position,
               :brand_colour)

  belongs_to :media_object, dependent: :destroy
  accepts_nested_attributes_for :media_object, allow_destroy: true

  delegate :settings_brand_opacity_enum, :settings_brand_position_enum,
           :settings_brand_colour_enum, to: :class

  delegate :file, :file=, to: :media_object
  attr_accessor :delete_file
  before_validation { file.clear if delete_file == '1' }

  has_paper_trail

  class << self
    def license_enum
      %w(CC0 CC_BY CC_BY_SA CC_BY_ND CC_BY_NC CC_BY_NC_SA CC_BY_NC_ND OOC PD_NC public RR_free RR_paid RR_restricted unknown orphan)
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
  end

  validates :license, inclusion: { in: license_enum }, allow_nil: true

  def media_object(*args)
    super || MediaObject.new
  end
end
