# frozen_string_literal: true

module Facet
  module URL
    extend ActiveSupport::Concern

    ##
    # URL for a facet item to link to
    #
    # If the facet item is already selected, this URL will remove it. If not, it
    # will add it.
    #
    # @param see {#facet_item}
    # @return [String] URL to add/remove the facet item from the search
    def facet_item_url(item)
      if facet_config.single
        replace_facet_url(item)
      else
        facet_in_params?(facet_name, item) ? remove_facet_url(item) : add_facet_url(item)
      end
    end

    def add_facet_url(item)
      rewrite_facet_url(:add, item)
    end

    def remove_facet_url(item)
      rewrite_facet_url(:remove, item)
    end

    def replace_facet_url(item)
      rewrite_facet_url(:replace, item)
    end

    def rewrite_facet_url(action, item)
      path = send(:"#{action}_facet_path", item)
      query = send(:"#{action}_facet_query", item)
      [path, query].reject(&:blank?).join('?')
    end

    def add_facet_path(_item)
      search_action_path
    end

    def remove_facet_path(_item)
      search_action_path
    end

    def replace_facet_path(_item)
      search_action_path
    end

    # @return [String] Request query string with the given facet item added
    def add_facet_query(item, base: facet_item_url_base_query)
      item_query = facet_cgi_query(facet_name, item.respond_to?(:value) ? item.value : item)
      [base, add_facet_parent_query, item_query].reject(&:blank?).join('&')
    end

    ##
    # Removes a facet item from request's query string
    #
    # @return [String] Request query string without the given facet item
    def remove_facet_query(item)
      item_query = Regexp.escape(facet_cgi_query(facet_name, item.respond_to?(:value) ? item.value : item))
      facet_item_url_base_query.dup.sub(/#{item_query}&?/, '')
    end

    def replace_facet_query(item)
      base = facet_item_url_base_query_params.deep_dup
      base[:f].delete(facet_name) if base[:f]
      add_facet_query(item, base: base.to_query)
    end

    def facet_item_url_base_query_params
      @facet_item_url_base_query_params ||= params.slice(:q, :f, :per_page, :view, :range)
    end

    def facet_item_url_base_query
      @facet_item_url_base_query ||= facet_item_url_base_query_params.to_query
    end

    def add_facet_parent_query
      return @add_facet_parent_query if instance_variable_defined?(:@add_facet_parent_query)
      @add_facet_parent_query = build_add_facet_parent_query
    end

    def build_add_facet_parent_query
      return nil unless parent_facet.present?

      facet_in_params?(parent_facet, @parent) ? nil : facet_cgi_query(parent_facet, @parent.value)
    end

    def facet_cgi_query(name, value)
      [CGI.escape("f[#{name}][]"), CGI.escape(value)].join('=')
    end
  end
end
