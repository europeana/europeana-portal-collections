# frozen_string_literal: true

##
# For views needing to display `Link::Promotion` objects
module PromotionLinkDisplayingView
  extend ActiveSupport::Concern

  protected

  def promoted_items(promotions)
    promotions.map do |promo|
      {
        category_label: promo.settings_category.presence ? t("global.promotions.#{promo.settings_category}") : false,
        featured: promo.position.nil? ? false : promo.position.zero?,
        hide_branding_text: promo.position.nil? ? false : promo.position.zero?,
        url: promo.url,
        is_external: !(URI(promo.url).host.blank? || URI(promo.url).host == request.host),
        title: promo.text,
        custom_class: promo.settings_class,
        wide: normalise_wide(promo.settings_wide),
        bg_image: promo&.file&.url(:xl)
      }
    end
  end

  def normalise_wide(promo_wide_setting)
    if @landing_page.layout_type == 'browse'
      false
    else
      promo_wide_setting == '1'
    end
  end
end
