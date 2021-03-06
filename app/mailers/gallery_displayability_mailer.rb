# frozen_string_literal: true

class GalleryDisplayabilityMailer < ApplicationMailer
  def post(gallery:, image_errors:)
    unless Rails.application.config.x.gallery.validation_mail_to.present?
      fail ApplicationMailer::Errors::NoRecipient, 'No gallery displayability report email recipient set.'
    end

    @gallery = gallery
    @image_errors = image_errors

    mail(to: Rails.application.config.x.gallery.validation_mail_to, subject: 'Gallery Displayability')
  end
end
