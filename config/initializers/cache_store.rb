Rails.application.configure do
  # Load Redis config from config/redis.yml, if it exists
  config.cache_store = begin
    redis_config = Rails.application.config_for(:redis).symbolize_keys
    fail RuntimeError unless redis_config.present?

    uri = URI::Generic.build(scheme: 'redis')
    uri.user = redis_config[:name]
    uri.password = redis_config[:password]
    uri.host = redis_config[:host]
    uri.port = redis_config[:port]
    uri.path = '/' + [redis_config[:db], redis_config[:namespace]].join('/')

    [:redis_store, uri.to_s]
  rescue RuntimeError
    :null_store
  end
end
