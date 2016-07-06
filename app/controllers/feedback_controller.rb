class FeedbackController < ApplicationController
  def create
    # @todo: fail here if mailer recipient not configured?
    if FeedbackMailer.post(mailer_post_args).deliver_later
      respond_to do |format|
        format.json { render json: { success: true } }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false }, status: 500 }
      end
    end
  end

  private

  def mailer_post_args
    { text: params[:text], type: params[:type], page: params[:page], ip: request.remote_ip }
  end
end
