class ErrorMailer < ApplicationMailer
  include ActionView::Helpers::TextHelper

  def report(exception, request)
    fail Errors::NoRecipient unless Rails.application.config.x.error_report_mail_to.present?

    @class = exception[:class]
    @message = truncate(exception[:message], length: 1000)
    @backtrace = Rails.backtrace_cleaner.clean(exception[:backtrace]).join("\n")
    @request_url = request[:original_url]
    @request_method = request[:method]
    @request_referer = request[:referer]

    mail(to: Rails.application.config.x.error_report_mail_to, subject: 'New portal error')
  end
end
