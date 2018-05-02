# frozen_string_literal: true

##
# Validate that a gallery has only properly displaying images
# Should an issue be discovered an email is sent to notify editors.
class GalleryValidationJob < ApplicationJob
  queue_as :default

  def perform(gallery_id)
    @gallery = Gallery.find(gallery_id)
    @portal_urls = []
    @validation_errors = {}

    validate_gallery_image_portal_urls

    if @validation_errors.present?
      @gallery.update_attribute(:image_errors, @validation_errors)
      notify
    else
      @gallery.set_images(@portal_urls)
      @gallery.update_attribute(:image_errors, nil)
    end
  end

  private

  def validate_gallery_image_portal_urls
    @gallery.image_portal_urls.each do |url|
      image = GalleryImage.from_portal_url(url)
      image.gallery = @gallery
      image.validating_with(:http_response, :europeana_record_api) do
        image.validate
        @validation_errors[url] = image.errors.messages.values.flatten if image.errors.present?
      end
      @portal_urls.push(image.portal_url)
    end
  end

  def notify
    return unless Rails.application.config.x.gallery.validation_mail_to.present?
    GalleryValidationMailer.post(gallery: @gallery, validation_errors: @validation_errors).deliver_later
  end
end
