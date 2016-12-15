##
# For views needing to display `Link::Promotion` objects
module PromotionLinkDisplayingView
  extend ActiveSupport::Concern

  protected

  def promoted_items(promotions)
    promotions.map do |promo|
      cat_flag = promo.settings_category.blank? ? {} : { :"is_#{promo.settings_category}" => true }
      {
        featured: promo.position.nil? ? false : promo.position.zero?,
        hide_branding_text: promo.position.nil? ? false : promo.position.zero?,
        url: promo.url,
        is_external: !(URI(promo.url).host.blank? || URI(promo.url).host == request.host),
        title: promo.text,
        custom_class: promo.settings_class,
        wide: promo.settings_wide == '1',
        bg_image: promo.file.nil? ? nil : promo.file.url
      }.merge(cat_flag)
    end
  end
end
