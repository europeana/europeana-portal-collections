class ErrorMailer < ApplicationMailer
  def report(message, backtrace, request_url, request_method)
    fail Errors::NoRecipient unless Rails.application.config.x.error_report_mail_to.present?
    @message = message
    @backtrace = backtrace.join("\n")
    @request_url = request_url
    @request_method = request_method
    mail(to: Rails.application.config.x.error_report_mail_to, subject: 'New portal error')
  end
end
