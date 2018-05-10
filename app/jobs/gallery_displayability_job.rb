# frozen_string_literal: true

# Ensure that a gallery has only displayable images
#
# All, and only, displayable images will be stored on the gallery.
#
# Any non-displayable images will be reported to editors by email.
class GalleryDisplayabilityJob < ApplicationJob
  queue_as :default

  def perform(gallery_id)
    @gallery = Gallery.find(gallery_id)
    @portal_urls = []
    @validation_errors = {}

    validate_gallery_image_portal_urls
    @gallery.set_images(@portal_urls)

    if @validation_errors.present?
      @gallery.update_attribute(:image_errors, @validation_errors)
      notify
    else
      @gallery.update_attribute(:image_errors, nil)
    end
  end

  private

  def validate_gallery_image_portal_urls
    @gallery.image_portal_urls.each do |url|
      image = GalleryImage.from_portal_url(url)
      image.gallery = @gallery
      validate_gallery_image(image)
    end
  end

  def validate_gallery_image(image)
    image.validating_with(:http_response, :europeana_record_api) do
      image.validate
      if image.errors.present?
        @validation_errors[url] = image.errors.messages.values.flatten
      else
        @portal_urls.push(image.portal_url)
      end
    end
  end

  def notify
    return unless Rails.application.config.x.gallery.validation_mail_to.present?
    GalleryValidationMailer.post(gallery: @gallery, validation_errors: @validation_errors).deliver_later
  end
end
