# frozen_string_literal: true
##
# For views needing to display galleries and their images
module GalleryDisplayingView
  extend ActiveSupport::Concern

  protected

  def gallery_image_thumbnail(image)
    presenter = presenter_for_gallery_image(image)
    return nil if presenter.nil?
    edm_preview = presenter.field_value('edmPreview')
    record_preview_url(edm_preview, 400)
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
    mustache[:head_meta] ||= begin
      head_meta = [
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
      facebook: {
        url: 'https://www.facebook.com/Europeana',
        text: 'Facebook'
      },
      twitter: {
        url: 'https://twitter.com/Europeanaeu',
        text: 'Twitter'
      },
      pinterest: {
        url: 'https://uk.pinterest.com/europeana/',
        text: 'Pinterest'
      },
      googleplus: {
        url: 'https://plus.google.com/+europeana/posts',
        text: 'Google Plus'
      },
      tumblr: {
        url: 'http://europeanacollections.tumblr.com/',
        text: 'Tumblr'
      }
    }
  end
end
