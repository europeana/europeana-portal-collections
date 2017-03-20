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
