# frozen_string_literal: true

##
# Validate that a gallery has only properly displaying images
# Should an issue be discovered an email is sent to notify editors.
class GalleryValidationJob < ApplicationJob
  queue_as :default

  def perform(gallery_id)
    fail 'No gallery validation email set.' unless Rails.application.config.x.gallery_validation_mail_to

    @gallery = Gallery.find(gallery_id)
    @validation_errors = {}

    validate_gallery_image_portal_urls

    if @validation_errors.present?
      # TODO: record errors on @gallery
      notify
    else
      @gallery.set_images_from_portal_urls if @gallery.image_portal_urls?
      # TODO: annotations...?
    end
  end

  private

  def validate_gallery_image_portal_urls
    @gallery.enumerable_image_portal_urls.each do |url|
      image = GalleryImage.from_portal_url(url)
      image.gallery = @gallery
      image.validating_with(:http_response, :europeana_record_api) do
        image.validate
        @validation_errors[url] = image.errors.messages.values.flatten if image.errors.present?
      end
    end
  end

  def notify
    GalleryValidationMailer.post(gallery: @gallery, validation_errors: @validation_errors).deliver_later
  end
end
