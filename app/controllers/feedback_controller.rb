class FeedbackController < ApplicationController
  def create
    # @todo: fail here if mailer recipient not configured?
    if FeedbackMailer.post(text: params[:text], type: params[:type], page: params[:page], ip: request.ip).deliver_later
      respond_to do |format|
        format.json { render json: { success: true } }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false }, status: 500 }
      end
    end
  end
end
