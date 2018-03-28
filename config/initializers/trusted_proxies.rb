# frozen_string_literal: truez

begin
  proxy_config = Rails.application.config_for(:proxies)
  proxy_ips = proxy_config.map { |proxy| IPAddr.new(proxy) }
  proxy_ips = ActionDispatch::RemoteIp::TRUSTED_PROXIES + proxy_ips
  Rails.application.config.action_dispatch.trusted_proxies = proxy_ips
rescue RuntimeError
end
