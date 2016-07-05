class FeedbackController < ApplicationController
  respond_to :json

  def create
    # @todo: fail here if mailer recipient not configured?
    args = params.slice(:text, :type, :url).merge(ip: request.ip)
    if FeedbackMailer.send(args).deliver_later
      respond_with(success: true)
    else
      respond_with({ success: false }, status: 500)
    end
  end
end
