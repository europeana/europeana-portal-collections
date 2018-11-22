# frozen_string_literal: true

module ExhibitionsHelper


  def exhibition_promo_content(exhibition)
    return if exhibition.blank?

    {
      url: exhibition.url,
      title: exhibition.title,
      description: exhibition.card_text,
      images: [exhibition.card_image],
      logo: exhibition.credit_image,
      type: I18n.t('global.promotions.exhibition')
    }
  end

  # Tags are not supported at this point.
  # def tag_items(exhibition)
  #   {
  #     items: exhibition.labels.map do |label|
  #       {
  #         url: exhibition.url,
  #         text: label
  #       }
  #     end + [{ url: exhibitions_url, text: I18n.t('global.promotions.exhibition') }]
  #   }
  # end

  def exhibitions_url(lang_code: 'en', slug: 'foyer')
    Rails.application.config.x.exhibitions.host + '/portal/' + lang_code + '/exhibitions/' + slug
  end
end
