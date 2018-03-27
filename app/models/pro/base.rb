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

    def has_authors?
      includes?(:persons)
    end

    def has_image?(attribute = :image)
      respond_to?(attribute) && send(attribute).is_a?(Hash)
    end

    def has_taxonomy?(name = nil)
      return false unless respond_to?(:taxonomy) && taxonomy.present?
      return true if name.nil?
      taxonomy.key?(name) && taxonomy[name].present?
    end

    def includes?(relation)
      last_result_set.included.has_link?(relation) &&
        respond_to?(relation) &&
        send(relation).flatten.compact.present?
    end

    def to_param
      respond_to?(:slug) ? slug : nil
    end

    def url
      [Pro.site, self.class.table_name, slug].join('/')
    end
  end
end
