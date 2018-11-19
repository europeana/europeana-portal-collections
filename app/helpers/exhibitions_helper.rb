# frozen_string_literal: true

module ExhibitionsHelper
  include UrlHelper

  def exhibition_content(exhibition)
    return {} if exhibition.nil?

    {
      url: exhibition.url,
      title: exhibition.title,
      description: exhibition.card_text,
      image: card_image(exhibition),
      logo_url: exhibition.credit_image,
      type: I18n.t('global.promotions.exhibition'),
      relation: I18n.t('site.object.promotions.card-labels.exhibition')
    }
  end

  def card_image(exhibition)
    exhibition.card_image
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
