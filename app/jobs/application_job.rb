##
# Base class job background jobs
class ApplicationJob < ActiveJob::Base
  include ActiveSupport::Benchmarkable

  rescue_from(StandardError) do |exception|
    return unless Rails.application.config.x.error_report_mail_to.present? # No email recipient configured

    ErrorMailer.report_job(
      { class: exception.class.to_s, message: exception.message, backtrace: exception.backtrace },
      { class: self.class.to_s, arguments: self.arguments.inspect }
    ).deliver_later

    raise exception
  end

#   def failure(job)
#     page_sysadmin_in_the_middle_of_the_night
#   end
end
