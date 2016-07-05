##
# Feedback form display methods
module FeedbackableView
  extend ActiveSupport::Concern

  def feedback
    {
      form_action: feedback_path,
      maxlength: 400
    }
  end
end
