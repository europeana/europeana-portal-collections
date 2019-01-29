# frozen_string_literal: true

##
# Display logic for facets.
#
# Responsible for generating data hashes for the Mustache templates from
# [Europeana's styleguide](https://github.com/europeana/europeana-styleguide-ruby)
# to display search result facet data.
class FacetPresenter < ApplicationPresenter
  include Facet::ItemDisplay
  include Facet::Labelling
  include Facet::URL
  include FacetsHelper
  include UrlHelper
  include ActionView::Helpers::NumberHelper

  attr_writer :facet_name
  attr_reader :controller

  ##
  # Factory to create an instance of the right presenter for a given facet field
  #
  # @param (see #initialize)
  # @return {FacetPresenter} subclass instance for the facet
  def self.build(facet, controller, blacklight_config = controller.blacklight_config, parent = nil)
    unless facet.nil?
      facet_config = blacklight_config.facet_fields[facet.name]
      class_for_facet(facet_config).new(facet, controller, blacklight_config, parent) unless facet_config.nil?
    end
  end

  ##
  # Get the presenter subclass for a facet
  #
  # Used by the factory method {.build}
  #
  # @param facet_config [Blacklight::Configuration::FacetField] Blacklight config
  #   for the facet field
  # @return [Class] subclass of {FacetPresenter} for use with the given facet
  def self.class_for_facet(facet_config)
    if facet_config.hierarchical && !facet_config.parent
      Facet::HierarchicalPresenter
    elsif facet_config.boolean
      Facet::BooleanPresenter
    elsif facet_config.colour
      Facet::ColourPresenter
    elsif facet_config.range
      Facet::RangePresenter
    elsif facet_config.key == 'COLLECTION'
      Facet::CollectionPresenter
    elsif facet_config.aliases
      Facet::AliasPresenter
    else
      Facet::SimplePresenter
    end
  end

  ##
  # @param facet [Europeana::Blacklight::Response::Facets::FacetField] facet
  #   field from Blacklight/Europeana search response.
  # @param controller [ApplicationController] controller processing the request
  # @param blacklight_config [Blacklight::Configuration] Blacklight configuration
  # @param parent [FacetPresenter] presenter for the parent field of a hierarchical
  #   child field
  def initialize(facet, controller, blacklight_config = controller.blacklight_config, parent = nil)
    @facet = facet
    @controller = controller
    @blacklight_config = blacklight_config
    @parent = parent
    @response = controller.instance_variable_get(:@response)
  end

  ##
  # Generates the data hash for a facet and its items
  #
  # @param options [Hash] Options passed on to other methods
  # @option options [Fixnum] :count The number of items to display up-front; any
  #  more will be hidden at first.
  # @return [Hash] display data for the facet
  def display(**options)
    items = items_to_show_and_hide(options).map { |group| group.map { |item| facet_item(item) } }

    {
      name: facet_name,
      title: facet_title,
      filter_open: filter_open?,
      select_one: facet_config.single,
      items: items.first,
      extra_items: items.last.blank? ? nil : { items: items.last },
      tooltip: facet_tooltip,
      icon_link: facet_icon_link
    }
  end

  def facet_title
    facet_config.respond_to?(:title) ? facet_config.title : facet_label
  end

  ##
  # Generates the data hash for one _available_ facet item
  #
  # This data is displayed in the list of _available_ facets. The facet may or
  # may not already be selected. Contrast with {#filter_item}.
  #
  # @param item [Europeana::Blacklight::Response::Facets::FacetItem] Blacklight/Europeana
  #   search result facet item
  # @return [Hash] display data for the facet item
  def facet_item(item)
    {
      url: facet_item_url(item),
      text: facet_item_label(item.value),
      num_results: number_with_delimiter(item.hits),
      is_checked: facet_in_params?(facet_name, item)
    }
  end

  ##
  # Generates the data hash for one _selected_ facet item
  #
  # This data is displayed in the list of _already selected_ facets. Contrast
  # with {#facet_item}.
  #
  # @param see {#facet_item}
  # @return [Hash] display data for the facet item
  def filter_item(item)
    {
      filter: facet_label,
      value: facet_item_label(item.value),
      remove: remove_facet_url(item),
      name: "f[#{facet_name}][]"
    }
  end

  def items_in_params
    @facet.items&.select { |item| facet_in_params?(facet_name, item) } || []
  end

  ##
  # Sometimes selected facets are not returned by the API, so we need to inject
  # them from the URL parameters.
  def items_from_params
    ips = items_in_params
    fps = [facet_params(facet_name)].flatten
    extras = fps.nil? ? [] : fps.reject { |fp| ips.any? { |ip| ip.value.downcase == fp.downcase } }
    ips + extras.map { |e| Europeana::Blacklight::Response::Facets::FacetItem.new(value: e) }
  end

  def facet_params(facet_name)
    super || default_facet_value
  end

  def filter_items
    items_from_params.reject { |item| default_facet_value?(item.value) }.map { |item| filter_item(item) }
  end

  def parent_facet
    @parent_facet ||= facet_config.parent.is_a?(Array) ? facet_config.parent.first : facet_config.parent
  end

  ##
  # Gets the Blacklight facet config for this facet field
  #
  # @return [Blacklight::Configuration::FacetField]
  def facet_config
    @facet_config ||= @blacklight_config.facet_fields[facet_name]
  end

  def default_facet_value?(value)
    value == default_facet_value
  end

  def filter_facet?
    !!facet_config.filter
  end

  def default_facet_value
    facet_config.default
  end

  private

  def facet_items
    @facet.items
  end

  def facet_name
    @facet_name ||= @facet.name
  end

  def filter_open?
    facet_items.select { |item| item.value.present? }.map do |item|
      facet_item(item)
    end.select { |item| item[:is_checked] }.count > 0
  end

  ##
  # Sends missing method calls to the controller
  def method_missing(method, *args)
    respond_to_missing?(method, true) ? @controller.send(method, *args) : super
  end

  def respond_to_missing?(method, _)
    @controller.respond_to?(method, true) || super
  end
end
