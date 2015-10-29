class ErrorMailer < ApplicationMailer
  include ActionView::Helpers::TextHelper

  def report(klass, message, backtrace, request_url, request_method)
    fail Errors::NoRecipient unless Rails.application.config.x.error_report_mail_to.present?

    @class = klass
    @message = truncate(message, length: 1000)
    @backtrace = Rails.backtrace_cleaner.clean(backtrace).join("\n")
    @request_url = request_url
    @request_method = request_method

    mail(to: Rails.application.config.x.error_report_mail_to, subject: 'New portal error')
  end
end
