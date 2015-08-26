class HeroImage < ActiveRecord::Base
  belongs_to :media_object
  accepts_nested_attributes_for :media_object

  serialize :attribution, HashWithIndifferentAccess
  serialize :brand, HashWithIndifferentAccess

  delegate :brand_circles_opacity_enum, :brand_circles_position_enum,
           :brand_circles_colour_enum, to: :class

  has_paper_trail

  class << self
    # Dynamic accessor methods for serialized Hash(like) attributes
    # @todo move into module for reuse in other models
    def define_dynamic_accessor_methods(methods = {})
      methods.each_pair do |attr, attr_meths|
        attr_meths.each do |meth|
          define_method("#{attr}_#{meth}") do
            self.send(attr.to_sym)[meth.to_sym]
          end
          define_method("#{attr}_#{meth}=") do |value|
            self.send(attr.to_sym)[meth.to_sym] = value
          end
        end
      end
    end

    def license_enum
      %w(CC0 CC-BY CC-BY-SA CC-BY-NC CC-BY-NC-ND CC-ND-NC-SA public)
    end

    def brand_circles_opacity_enum
      [25, 50, 75, 100]
    end

    def brand_circles_position_enum
      %w(topleft topright bottomleft bottomright)
    end

    def brand_circles_colour_enum
      %w(site white black)
    end
  end

  validates :license, inclusion: {
    in: license_enum
  }, allow_nil: true

  define_dynamic_accessor_methods(
    attribution: %w(title creator institution url text),
    brand: %w(circles_opacity circles_position circles_colour)
  )
end
