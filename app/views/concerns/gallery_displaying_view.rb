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
end
