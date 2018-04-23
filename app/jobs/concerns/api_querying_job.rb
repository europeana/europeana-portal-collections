# frozen_string_literal: true

module ApiQueryingJob
  extend ActiveSupport::Concern

  include Blacklight::RequestBuilders

  class_methods do
    attr_accessor :facets

    def requests_facet(name, **settings)
      @facets ||= {}
      @facets[name] = settings
    end
  end

  def blacklight_config
    @blacklight_config ||= begin
      PortalController.new.blacklight_config.deep_dup.tap do |blacklight_config|
        unless self.class.facets.blank?
          blacklight_config.facet_fields.select! { |name, _config| self.class.facets.key?(name) }
          self.class.facets.each_pair do |name, settings|
            settings.each_pair do |key, value|
              blacklight_config.facet_fields[name][key] = value
            end
          end
        end
      end
    end
  end

  def repository
    @repository ||= repository_class.new(blacklight_config)
  end

  def repository_class
    blacklight_config.repository_class
  end

  def cache_query_count(api_query, cache_key)
    repository.search(api_query).total.tap do |count|
      Rails.cache.write(cache_key, count)
    end
  end

  protected

  def api_query
    fail NotImplementedError, 'Including classes need to define #api_query'
  end

  def response
    repository.search(api_query)
  end

  def facet_api_query
    api_query = search_builder.rows(0).merge(query: '*:*', profile: 'minimal facets')
    api_query.with_overlay_params(@collection.api_params_hash) unless @collection.nil?
    api_query
  end

  def facet_response
    repository.search(facet_api_query)
  end
end
