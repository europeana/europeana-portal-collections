# frozen_string_literal: true

##
# Base class job background jobs
class ApplicationJob < ActiveJob::Base
  include ActiveSupport::Benchmarkable

  rescue_from(StandardError) do |exception|
    if Rails.application.config.x.error_report_mail_to.present? # No email recipient configured
      ErrorMailer.report_job(
        exception: { class: exception.class.to_s, message: exception.message, backtrace: exception.backtrace },
        job: { class: self.class.to_s, arguments: arguments.inspect }
      ).deliver_later

      raise exception
    end
  end
end
