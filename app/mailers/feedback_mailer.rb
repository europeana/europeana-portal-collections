class FeedbackMailer < ApplicationMailer
  def post(text:, type:, page:, ip:)
    fail Errors::NoRecipient unless Rails.application.config.x.feedback_mail_to.present?

    @text = text
    @type = type
    @page = page
    @ip = ip

    mail(to: Rails.application.config.x.feedback_mail_to, subject: 'User feedback')
  end
end
