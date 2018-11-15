# frozen_string_literal: true

module ExhibitionsHelper
  include UrlHelper

  def exhibition_content(exhibition)
    return {} if exhibition.nil?

    {
      url: exhibition.url,
      state_2_body: exhibition.card_text,
      state_3_logo: {
        thumbnail: {
          url: exhibition.credit_image
        }
      },
      state_1_label: false,
      state_1_image: card_image(exhibition),
      state_2_image: card_image(exhibition),
      state_3_image: card_image(exhibition),
      excerpt: false,
      icon: 'multi-page',
      title: exhibition.title,
      relation: I18n.t('site.object.promotions.card-labels.exhibition')
    }
  end

  def card_image(exhibition)
    {
      thumbnail: {
        url: exhibition.card_image
      }
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
