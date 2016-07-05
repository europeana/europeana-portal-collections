module FeedbackableView
  def feedback
    {
      form_action: feedback_path,
      maxlength: 400
    }
  end
end
