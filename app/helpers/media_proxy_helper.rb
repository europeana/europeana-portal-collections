# frozen_string_literal: true

module MediaProxyHelper
  def media_proxy_configured?
    Rails.application.config.x.europeana_media_proxy.present?
  end

  def media_proxy_url(record_id, web_resource_url)
    return web_resource_url unless media_proxy_configured?
    Rails.application.config.x.europeana_media_proxy + record_id + '?view=' + CGI.escape(web_resource_url)
  end
end
