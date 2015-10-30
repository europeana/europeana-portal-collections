class ApplicationMailer < ActionMailer::Base
  module Errors
    NoRecipient = Class.new(StandardError)
  end

  default from: 'no-reply@europeana.eu'

  layout 'mailer'
end
