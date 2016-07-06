# frozen_string_literal: true

##
# Methods used by feedback controller and views
module FeedbackHelper
  def feedback_enabled?
    Rails.application.config.x.feedback_mail_to.present?
  end
end
