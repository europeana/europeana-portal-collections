##
# For views needing to display `HeroImage` objects
module HeroImageDisplayingView
  extend ActiveSupport::Concern

  LICENSES_URL = {
    'public' => 'https://creativecommons.org/publicdomain/mark/1.0/',
    'CC0' => 'https://creativecommons.org/publicdomain/zero/1.0/',
    'CC_BY' => 'https://creativecommons.org/licenses/by/1.0',
    'CC_BY_SA' => 'https://creativecommons.org/licenses/by-sa/1.0',
    'CC_BY_ND' => 'https://creativecommons.org/licenses/by-nc-nd/1.0',
    'CC_BY_NC' => 'https://creativecommons.org/licenses/by-nc/1.0',
    'CC_BY_NC_SA' => 'https://creativecommons.org/licenses/by-nc-sa/1.0',
    'CC_BY_NC_ND' => 'https://creativecommons.org/licenses/by-nc-nd/1.0',
    'RS_INC_EDU' => 'http://rightsstatements.org/vocab/InC-EDU/1.0/',
    'RS_NOC_OKLR' => 'http://rightsstatements.org/vocab/NoC-OKLR/1.0/',
    'RS_INC' => 'http://rightsstatements.org/vocab/InC/1.0/',
    'RS_NOC_NC' => 'http://rightsstatements.org/vocab/NoC-NC/1.0/',
    'RS_INC_OW_EU' => 'http://rightsstatements.org/vocab/InC-OW-EU/1.0/',
    'RS_CNE' => 'http://rightsstatements.org/vocab/CNE/1.0/'
  }

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
    if hero_image.license.blank?
      {}
    else
      {
        hero_license_template_var_name(hero_image.license) => true,
        license_url: LICENSES_URL[hero_image.license]
      }
    end
  end

  def hero_license_template_var_name(license)
    'license_' + license.tr('-', '_')
  end
end
