##
# Feedback form display methods
module FeedbackableView
  extend ActiveSupport::Concern

  def feedback
    return nil unless feedback_enabled?
    {
      form_action: feedback_path,
      maxlength: 400
    }
  end
end
