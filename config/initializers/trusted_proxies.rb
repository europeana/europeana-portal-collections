begin
  proxy_config = Rails.application.config_for(:proxies)
  proxy_ips = proxy_config.map { |proxy| IPAddr.new(proxy) }
  Rails.application.config.action_dispatch.trusted_proxies = proxy_ips
rescue RuntimeError
end
