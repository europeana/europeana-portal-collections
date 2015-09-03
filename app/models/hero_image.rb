class HeroImage < ActiveRecord::Base
  include RecordSettingsHash

  has_record_settings_hash(:attribution, %w(title creator institution url text))
  has_record_settings_hash(:brand, %w(opacity position colour))

  belongs_to :media_object
  accepts_nested_attributes_for :media_object
  attr_accessor :delete_media_object
  before_validation { self.media_object.clear if self.delete_media_object == '1' }

  delegate :brand_opacity_enum, :brand_position_enum,
           :brand_colour_enum, to: :class

  delegate :file, to: :media_object

  has_paper_trail

  class << self
    def license_enum
      %w(CC0 CC_BY CC_BY_SA CC_BY_ND CC_BY_NC CC_BY_NC_SA CC_BY_NC_ND OOC PD_NC public RR_free RR_paid RR_restricted unknown orphan)
    end

    def brand_opacity_enum
      [25, 50, 75, 100]
    end

    def brand_position_enum
      %w(topleft topright bottomleft bottomright)
    end

    def brand_colour_enum
      %w(site white black)
    end
  end

  validates :license, inclusion: { in: license_enum }, allow_nil: true

  after_initialize do
    build_media_object if self.media_object.nil?
  end
end
