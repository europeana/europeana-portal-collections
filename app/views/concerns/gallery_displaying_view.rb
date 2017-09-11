# frozen_string_literal: true
##
# For views needing to display galleries and their images
module GalleryDisplayingView
  extend ActiveSupport::Concern

  include MediaProxyHelper
  include ThumbnailHelper

  protected

  def gallery_image_thumbnail(image)
    presenter = presenter_for_gallery_image(image)
    return nil if presenter.nil?
    edm_preview = presenter.field_value('edmPreview')
    thumbnail_url_for_edm_preview(edm_preview, size: 400, source: :s3)
  end

  def gallery_image_full(image)
    presenter = presenter_for_gallery_image(image)
    return nil if presenter.nil?
    edm_is_shown_by = presenter.field_value('aggregations.edmIsShownBy')
    full_url(image, edm_is_shown_by)
  end

  def full_url(image, edm_is_shown_by)
    full_urls[image.id] ||= media_proxy_url(image.europeana_record_id, edm_is_shown_by)
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
