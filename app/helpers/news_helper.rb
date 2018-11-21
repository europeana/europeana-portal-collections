# frozen_string_literal: true

module NewsHelper
  # Constructs a promo card from a Pro JSON API post
  #
  # @param post [Pro::Post]
  # @return [Hash]
  def news_promo_content(post)
    return nil if post.nil?
    {
      url: post.url,
      title: post.attributes[:title],
      date: Date.parse(post.attributes[:datepublish]).to_formatted_s(:db),
      attribution: post.attributes[:image_attribution_holder],
      description: post.attributes[:teaser],
      type: I18n.t('site.object.promotions.type.news'),
      images: post.attributes[:image].present? ? [post.attributes[:image][:thumbnail]] : []
    }
  end
end
