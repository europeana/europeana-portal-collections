# frozen_string_literal: true

module ExhibitionsHelper
  include UrlHelper

  def exhibition_content(exhibition)
    return {} if exhibition.nil?

    {
      url: exhibition.url,
      state_1_title: exhibition.title,
      state_2_body: exhibition.description,
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
      relation: 'Features this object', # Should be in localeapp once finalized
      tags: tag_items(exhibition)
    }
  end

  def card_image(exhibition)
    {
      thumbnail: {
        url: exhibition.card_image
      }
    }
  end

  def tag_items(exhibition)
    {
      items: exhibition.labels.map do |label|
        {
          url: exhibition.url,
          text: label
        }
      end + [{ url: exhibitions_url, text: I18n.t('global.promotions.exhibition') }]
    }
  end

  def exhibitions_base_url
    Rails.application.config.x.exhibitions.host_url.present? ? Rails.application.config.x.exhibitions.host_url : root_url
  end

  def exhibitions_url(lang_code: 'en', slug: 'foyer')
    exhibitions_base_url + 'portal/' + lang_code + '/exhibitions/' + slug
  end
end
