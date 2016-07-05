class FeedbackMailer < ApplicationMailer
  def send(text: text, type: type, url: url, ip: ip)
    fail Errors::NoRecipient unless Rails.application.config.x.feedback_mail_to.present?

    @text = text
    @type = type
    @url = url
    @ip = ip

    mail(to: Rails.application.config.x.feedback_mail_to, subject: 'User feedback')
  end
end
