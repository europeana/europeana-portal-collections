class HeroImage < ActiveRecord::Base
  include DynamicAccessorMethods

  has_dynamic_accessor_methods(
    attribution: %w(title creator institution url text),
    brand: %w(opacity position colour)
  )

  belongs_to :media_object
  accepts_nested_attributes_for :media_object
  attr_accessor :delete_media_object
  before_validation { self.media_object.clear if self.delete_media_object == '1' }

  serialize :attribution, HashWithIndifferentAccess
  serialize :brand, HashWithIndifferentAccess

  delegate :brand_opacity_enum, :brand_position_enum,
           :brand_colour_enum, to: :class

  delegate :file, to: :media_object

  has_paper_trail

  class << self
    def license_enum
      %w(CC0 CC-BY CC-BY-SA CC-BY-NC CC-BY-NC-ND CC-ND-NC-SA public)
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

  validates :license, inclusion: {
    in: license_enum
  }, allow_nil: true

  after_initialize do
    build_media_object if self.media_object.nil?
  end
end
