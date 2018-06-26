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

  # @param browse_entry [BrowseEntry]
  # @param page [Page]
  # @return [String] url
  def search_url_with_query(query, page = nil, **options)
    parsed_query = Rack::Utils.parse_nested_query(query)
    url_options = parsed_query.reverse_merge(options)
    url_options['q'] ||= ''

    if page.present? && (slug_match = page.slug.match(/\Acollections\/(.*)\Z/))
      collection = Collection.find_by_key(slug_match[1])
      return collection_url(collection.key, url_options) unless collection.nil?
    end

    search_url(url_options)
  end

  def enquote_and_escape(val)
    '"' +  val.gsub('"', '\\"') + '"'
  end

  def parenthesise_and_escape(val)
    '(' +  val.gsub('(', '\\(').gsub(')', '\\)') + ')'
  end

  def exhibitions_path(locale = I18n.locale)
    home_path(locale: locale) + '/exhibitions'
  end

  def exhibitions_foyer_path(locale = I18n.locale)
    exhibitions_path(locale) + '/foyer'
  end
end
