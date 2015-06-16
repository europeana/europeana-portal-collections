##
# URL helpers
#
# @see Blacklight::UrlHelperBehavior
module UrlHelper
  include Blacklight::UrlHelperBehavior

  def add_facet_params(field, item, source_params = params)
    return super unless field == 'CHANNEL'

    value = facet_value_for_facet_item(item)

    p = reset_search_params(source_params)
    p[:controller] = :channels
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
    p = reset_search_params(source_params)
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
    reset_search_params(source_params).tap do |p|
      if p[:qf].blank?
        p.delete(:q)
      else
        p[:q] = p[:qf].shift
      end
    end
  end
end
