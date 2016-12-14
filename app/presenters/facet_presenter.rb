##
# Display logic for facets.
#
# Responsible for generating data hashes for the Mustache templates from
# [Europeana's styleguide](https://github.com/europeana/europeana-styleguide-ruby)
# to display search result facet data.
class FacetPresenter
  include Facet::Labelling
  include FacetsHelper
  include UrlHelper
  include ActionView::Helpers::NumberHelper
  delegate :t, to: I18n

  attr_writer :facet_name
  attr_reader :controller

  ##
  # Factory to create an instance of the right presenter for a given facet field
  #
  # @param (see #initialize)
  # @return {FacetPresenter} subclass instance for the facet
  def self.build(facet, controller, blacklight_config = controller.blacklight_config, parent = nil)
    if !facet.nil?
      facet_config = blacklight_config.facet_fields[facet.name]
      class_for_facet(facet_config).new(facet, controller, blacklight_config, parent)
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
    case
    when facet_config.hierarchical && !facet_config.parent
      Facet::HierarchicalPresenter
    when facet_config.boolean
      Facet::BooleanPresenter
    when facet_config.colour
      Facet::ColourPresenter
    when facet_config.range
      Facet::RangePresenter
    when facet_config.key == 'COLLECTION'
      Facet::CollectionPresenter
    when facet_config.aliases
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
    options.reverse_merge!(count: 5)

    display_items = items_to_display(options)
    if display_items.is_a?(Array)
      unhidden_items = display_items.first
      hidden_items = display_items.last
    else
      unhidden_items = display_items
      hidden_items = nil
    end

    {
      name: facet_name,
      title: facet_config.respond_to?(:title) ? facet_config.title : facet_label,
      filter_open: filter_open?,
      select_one: facet_config.single,
      items: unhidden_items.map { |item| facet_item(item) },
      extra_items: hidden_items.blank? ? nil : {
        items: hidden_items.map { |item| facet_item(item) }
      },
      tooltip: facet_tooltip,
      icon_link: facet_icon_link
    }
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
      remove: facet_item_url(item),
      name: "f[#{facet_name}][]"
    }
  end

  def items_in_params
    @facet.items.select { |item| facet_in_params?(facet_name, item) }
  end

  ##
  # Sometimes selected facets are not returned by the API, so we need to inject
  # them from the URL parameters.
  def items_from_params
    ips = items_in_params
    fps = facet_params(facet_name)
    extras = fps.nil? ? [] : fps.reject { |fp| ips.any? { |ip| ip.value == fp } }
    ips + extras.map { |e| Europeana::Blacklight::Response::Facets::FacetItem.new(value: e) }
  end

  def filter_items
    items_from_params.map { |item| filter_item(item) }
  end

  ##
  # URL for a facet item to link to
  #
  # If the facet item is already selected, this URL will remove it. If not, it
  # will add it.
  #
  # @param see {#facet_item}
  # @return [String] URL to add/remove the facet item from the search
  def facet_item_url(item)
    if facet_in_params?(facet_name, item)
      search_action_url(remove_facet_params(item))
    else
      search_action_url(add_facet_params(item))
    end
  end

  ##
  # Removes a facet item from request's parameters
  #
  # @param see {#facet_item}
  # @return [Hash] Request parameters without the given facet item
  def remove_facet_params(item)
    search_state.remove_facet_params(facet_name, item)
  end

  def add_facet_params(item)
    facet_params = search_state.add_facet_params_and_redirect(facet_name, item)
    if @parent && facet_config.parent
      parent_facet = facet_config.parent.is_a?(Array) ? facet_config.parent.first : facet_config.parent
      unless facet_in_params?(parent_facet, @parent)
        tmp_search_state = Blacklight::SearchState.new(ActionController::Parameters.new(facet_params), @blacklight_config)
        facet_params = tmp_search_state.add_facet_params(parent_facet, @parent)
      end
    end
    facet_params
  end

  ##
  # Gets the Blacklight facet config for this facet field
  #
  # @return [Blacklight::Configuration::FacetField]
  def facet_config
    @facet_config ||= @blacklight_config.facet_fields[facet_name]
  end

  private

  def items_to_display(**options)
    items = facet_items.dup
    %i{only order splice split}.each do |mod|
      items = send(:"apply_#{mod}_to_items", items, options) if send(:"apply_#{mod}_to_items?")
    end
    items
  end

  def apply_only_to_items?
    facet_config.only.present?
  end

  def apply_order_to_items?
    true
  end

  def apply_splice_to_items?
    facet_config.splice.present? && facet_config.parent.present?
  end

  def apply_split_to_items?
    true
  end

  def apply_only_to_items(items, **_)
    items.select { |item| facet_config.only.call(item) }
  end

  def apply_order_to_items(items, **_)
    items
  end

  def apply_splice_to_items(items, **_)
    items.select { |item| facet_config.splice.call(@parent, item) } if facet_config.splice.present?
  end

  ##
  # Splits the facet's items into two sets, one to be shown, the other hidden
  #
  # All currently selected facet items will be shown, regardless of the value of
  # the `count` option.
  #
  # After all selected facet items, other non-selected facet items will be
  # included in the set to show, up to a maximum set by the `count` option.
  #
  # All other items will be in the hidden set.
  #
  # @return [Array<Array>] Two arrays of facet items, first to show, last to hide
  def apply_split_to_items(items, **options)
    unhidden_items = []
    hidden_items = items

    unless facet_config.single
      hidden_items.select { |item| facet_in_params?(facet_name, item) }.each do |selected_item|
        unhidden_items << hidden_items.delete(selected_item)
      end
    end
    while (unhidden_items.size < options[:count]) && hidden_items.present?
      unhidden_items.push(hidden_items.shift)
    end
    [unhidden_items, hidden_items]
  end

  def facet_items
    @facet.items
  end

  def facet_name
    @facet_name ||= @facet.name
  end

  def filter_open?
    facet_items.select{ |item| item.value.present?}.map { |item|
      facet_item(item)
    }.select{|item| item[:is_checked]}.count > 0
  end

  ##
  # Sends missing method calls to the controller
  def method_missing(method, *args)
    @controller.send(method, *args)
  end
end
