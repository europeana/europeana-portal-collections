##
# For views needing to display `HeroImage` objects
module HeroImageDisplayingView
  extend ActiveSupport::Concern

  protected

  def hero_config(hero_image)
    return nil unless hero_image.present?
    {
      hero_image: hero_image.file.present? ? hero_image.file.url : nil,
      attribution_title: hero_image.settings_attribution_title,
      attribution_creator: hero_image.settings_attribution_creator,
      attribution_institution: hero_image.settings_attribution_institution,
      attribution_url: hero_image.settings_attribution_url,
      attribution_text: hero_image.settings_attribution_text,
      brand_opacity: "brand-opacity#{hero_image.settings_brand_opacity}",
      brand_position: "brand-#{hero_image.settings_brand_position}",
      brand_colour: "brand-colour-#{hero_image.settings_brand_colour}"
    }.merge(hero_license(hero_image)).merge(hero_ripple_width(hero_image))
  end

  def hero_ripple_width(hero_image)
    hero_image.settings_ripple_width.blank? ? {} : { "ripple_size_#{hero_image.settings_ripple_width}" => true }
  end

  def hero_license(hero_image)
    hero_image.license.blank? ? {} : { hero_license_template_var_name(hero_image.license) => true }
  end

  def hero_license_template_var_name(license)
    'license_' + license.tr('-', '_')
  end
end
