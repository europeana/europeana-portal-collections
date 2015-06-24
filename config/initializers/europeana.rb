if ENV['EUROPEANA_API_URL']
  require 'europeana/api'
  Europeana::API.url = ENV['EUROPEANA_API_URL']
end
