# frozen_string_literal: true

module ApiHelper
  def api_url
    respond_to?(:params) && params[:api_url] ? params[:api_url] : Europeana::API.url
  end
end
