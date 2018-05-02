# frozen_string_literal: true

class GalleryValidationMailer < ApplicationMailer
  def post(gallery:, validation_errors:)
    fail 'No gallery validation email set.' unless Rails.application.config.x.gallery.validation_mail_to

    @gallery = gallery
    @validation_errors = validation_errors

    mail(to: Rails.application.config.x.gallery.validation_mail_to, subject: 'Gallery validation')
  end
end
