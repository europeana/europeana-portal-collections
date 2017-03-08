# frozen_string_literal: true
module Pro
  ##
  # Base class for JSON-API resources consumed from the Europeana Pro Bolt CMS
  # via its json-api extension.
  class Base < JsonApiClient::Resource
    self.site = (ENV['EUROPEANA_PRO_URL'] || 'http://pro.europeana.eu') + '/json/'

    def self.table_name
      to_s.pluralize.demodulize.downcase
    end
  end
end
