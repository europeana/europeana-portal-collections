# frozen_string_literal: true
##
# For views needing to display galleries and their images
module GalleryDisplayingView
  extend ActiveSupport::Concern

  include GalleryHelper
  include MediaProxyHelper
  include ThumbnailHelper

  protected

  def gallery_image_full(image)
    full_urls[image.id] ||= media_proxy_url(image.europeana_record_id, image.url)
  end

  def full_urls
    @full_urls ||= {}
  end

  def presenter_for_gallery_image(image)
    @presenters ||= {}
    @presenters[image.id] ||= begin
      document = document_for_gallery_image(image)
      document.nil? ? nil : Document::SearchResultPresenter.new(document, controller)
    end
  end

  def document_for_gallery_image(image)
    @documents.detect { |document| document.fetch(:id, nil) == image.europeana_record_id }
  end

  def gallery_head_meta
    mustache[:gallery_head_meta] ||= begin
      [
        { meta_property: 'fb:appid', content: '185778248173748' },
        { meta_name: 'twitter:card', content: 'summary' },
        { meta_name: 'twitter:site', content: '@EuropeanaEU' },
        { meta_property: 'og:url', content: request.original_url }
      ]
    end
  end

  def gallery_social_links
    {
      style_blue: true,
      url: request.original_url,
      facebook: {
        text: 'Facebook'
      },
      twitter: {
        text: 'Twitter'
      },
      pinterest: {
        text: 'Pinterest'
      },
      googleplus: {
        text: 'Google Plus'
      },
      tumblr: {
        text: 'Tumblr'
      }
    }
  end
end
