# frozen_string_literal: true

module MediaProxyHelper
  include ApiHelper

  def media_proxy_configured?
    Rails.application.config.x.europeana_media_proxy.present?
  end

  def media_proxy_url(record_id, web_resource_url, **options)
    return web_resource_url unless media_proxy_configured?
    proxy_params = { view: web_resource_url, api_url: api_url }.reverse_merge(options)
    Rails.application.config.x.europeana_media_proxy + record_id + '?' + proxy_params.to_query
  end
end
