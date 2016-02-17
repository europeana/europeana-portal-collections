##
# URL helpers
#
# @see Blacklight::UrlHelperBehavior
module UrlHelper
  include Blacklight::UrlHelperBehavior

  def add_facet_params(field, item, source_params = params)
    return super unless field == 'COLLECTION'

    value = facet_value_for_facet_item(item)

    p = Blacklight::SearchState.new(source_params, blacklight_config).send(:reset_search_params)
    p[:controller] = :collections
    p[:action] = :show
    p[:id] = value

    p
  end

  ##
  # Remove one value from an Array of params
  #
  # @param key [Symbol, String] Key of parameter to remove
  # @param value Value to remove from params
  # @param source_params [Hash] params to remove from
  # @return [Hash] a copy of params with the passed value removed
  def remove_search_param(key, value, source_params = params)
    p = Blacklight::SearchState.new(source_params, blacklight_config).send(:reset_search_params)
    p[key] = ([p[key]].flatten || []).dup
    p[key] = p[key] - [value]
    p.delete(key) if p[key].empty?
    p
  end

  ##
  # Remove q param, shifting first qf param (if any) to q
  #
  # @param source_params [Hash] params to operate on
  # @return [Hash] modified params
  def remove_q_param(source_params = params)
    Blacklight::SearchState.new(source_params, blacklight_config).send(:reset_search_params).tap do |p|
      if p[:qf].blank?
        p.delete(:q)
      else
        p[:q] = [p[:qf]].flatten.shift
      end
    end
  end

  # @param page [Page]
  # @param browse_entry [BrowseEntry]
  # @return [String] url
  def browse_entry_url(browse_entry, page = nil)
    if page.present? && (slug_match = page.slug.match(/\Acollections\/(.*)\Z/))
      collection = Collection.find_by_key(slug_match[1])
      return collection_path(collection.key, q: browse_entry.query) unless collection.nil?
    end
    search_path(q: browse_entry.query)
  end
end
