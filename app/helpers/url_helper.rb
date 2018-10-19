# frozen_string_literal: true

##
# URL helpers
#
# @see Blacklight::UrlHelperBehavior
module UrlHelper
  include Blacklight::UrlHelperBehavior

  # @see Catalog
  delegate :search_action_path, :search_action_url, to: :controller

  ##
  # Remove one value from an Array or Hash of params
  #
  # @param key [Symbol, String] Key of parameter to remove
  # @param value Value to remove from params
  # @param source_params [Hash] params to remove from
  # @return [Hash] a copy of params with the passed value removed
  def remove_search_param(key, value, source_params = params)
    Blacklight::SearchState.new(source_params, blacklight_config).send(:reset_search_params).tap do |search_params|
      search_params.delete(:locale)

      if search_params[key].is_a?(Hash)
        key_for_value = search_params[key].key(value)
        search_params[key].delete(key_for_value)
      else
        search_params[key] = ([search_params[key]].flatten || []).dup
        search_params[key] = search_params[key] - [value]
      end
      search_params.delete(key) if search_params[key].blank?
    end
  end

  ##
  # Remove q param, shifting first qf param (if any) to q
  #
  # @param source_params [Hash] params to operate on
  # @return [Hash] modified params
  def remove_q_param(source_params = params)
    Blacklight::SearchState.new(source_params, blacklight_config).send(:reset_search_params).tap do |search_params|
      search_params.delete(:locale)

      search_params[:q] = if search_params[:qf].blank?
                            ''
                          elsif search_params[:qf].is_a?(Array)
                            search_params[:qf].shift
                          else
                            search_params.delete(:qf)
                          end
    end
  end

  def browse_entry_url(browse_entry, page = nil, **options)
    search_url_with_query(browse_entry.query, page, options)
  end

  def browse_entry_path(browse_entry, page = nil, options = {})
    browse_entry_url(browse_entry, page, options.merge(only_path: true))
  end

  # Construct a URL for a search page with the specified query
  #
  # @param query [String] URL query string from the Portal for a search
  # @param page [Page] If a Collection landing page, search in this collection
  # @param options [Hash] Any additional options are passed on to Rails' URL generators
  # @return [String] URL for the search page
  def search_url_with_query(query, page = nil, **options)
    url_options = search_url_with_query_url_options(query, **options)

    if page.present? && (slug_match = page.slug.match(/\Acollections\/(.*)\Z/))
      collection = Collection.find_by_key(slug_match[1])
      return collection_url(collection.key, url_options) unless collection.nil?
    end

    search_url(url_options)
  end

  # URL options for +#search_url_with_query+
  #
  # @param query [String] URL query string from the Portal for a search
  # @param options [Hash] Any additional options are passed on to Rails' URL generators
  def search_url_with_query_url_options(query, **options)
    parsed_query = Rack::Utils.parse_nested_query(query)
    parsed_query.reverse_merge(options).tap do |url_options|
      url_options['q'] ||= ''
    end
  end

  def exhibitions_path(locale = I18n.locale)
    home_path(locale: locale) + '/exhibitions'
  end

  def exhibitions_foyer_path(locale = I18n.locale)
    exhibitions_path(locale) + '/foyer'
  end
end
