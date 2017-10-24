# frozen_string_literal: true

class GalleryValidationMailer < ApplicationMailer
  def post(gallery:, validation_errors:)
    @gallery = gallery
    @validation_errors = validation_errors

    mail(to: Rails.application.config.x.gallery_validation_mail_to, subject: 'Automated Gallery Validation')
  end
end