# frozen_string_literal: true
module Pro
  ##
  # Base class for JSON-API resources consumed from the Europeana Pro Bolt CMS
  # via its json-api extension.
  class Base < JsonApiClient::Resource
    self.site = Pro.site + '/json/'

    connection do |connection|
      # Log and time JSON API request URLs
      connection.use Faraday::Request::Instrumentation
    end

    def to_param
      respond_to?(:slug) ? slug : nil
    end

    def url
      [Pro.site, self.class.table_name, slug].join('/')
    end
  end
end
