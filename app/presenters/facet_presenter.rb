##
# Display logic for facets.
#
# Responsible for generating data hashes for the Mustache templates from
# [Europeana's styleguide](https://github.com/europeana/europeana-styleguide-ruby)
# to display search result facet data.
class FacetPresenter
  include FacetsHelper
  include UrlHelper
  include ActionView::Helpers::NumberHelper
  delegate :t, to: I18n

  ##
  # Factory to create an instance of the right presenter for a given facet field
  #
  # @param (see #initialize)
  # @return {FacetPresenter} subclass instance for the facet
  def self.build(facet, controller, blacklight_config = controller.blacklight_config)
    facet_config = blacklight_config.facet_fields[facet.name]
    class_for_facet(facet_config).new(facet, controller, blacklight_config)
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
    else
      Facet::SimplePresenter
    end
  end

  ##
  # @param facet [Europeana::Blacklight::Response::Facets::FacetField] facet
  #   field from Blacklight/Europeana search response.
  # @param controller [ApplicationController] controller processing the request
  # @param blacklight_config [Blacklight::Configuration] Blacklight configuration
  def initialize(facet, controller, blacklight_config = controller.blacklight_config)
    @facet = facet
    @blacklight_config = blacklight_config
    @controller = controller
    @response = controller.instance_variable_get(:@response)
  end

  ##
  # Generates the data hash for a facet and its items
  #
  # @param options [Hash] Options
  # @option options [Fixnum] :count The number of items to display up-front; any
  #  more will be hidden at first.
  # @return [Hash] display data for the facet
  def display(options = {})
    options = options.reverse_merge(count: 5)
    unhidden_items, hidden_items = split_items(options[:count])
    {
      title: facet_label(@facet.name),
      select_one: facet_config.single,
      items: unhidden_items.map { |item| facet_item(item) },
      extra_items: hidden_items.blank? ? nil : {
        items: hidden_items.map { |item| facet_item(item) }
      }
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
      text: facet_label(@facet.name, item.value),
      num_results: number_with_delimiter(item.hits),
      is_checked: facet_in_params?(@facet.name, item)
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
      filter: facet_label(@facet.name),
      value: facet_label(@facet.name, item.value),
      remove: facet_item_url(item),
      name: "f[#{@facet.name}][]"
    }
  end

  ##
  # Removes a facet item from request's parameters
  #
  # @param see {#facet_item}
  # @return [Hash] Request parameters without the given facet item
  def remove_facet_params(item)
    search_state.remove_facet_params(@facet.name, item)
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
    if facet_in_params?(@facet.name, item)
      search_action_url(remove_facet_params(item))
    else
      search_action_url(search_state.add_facet_params_and_redirect(@facet.name, item))
    end
  end

  ##
  # Gets the Blacklight facet config for this facet field
  #
  # @return [Blacklight::Configuration::FacetField]
  def facet_config
    @facet_config ||= @blacklight_config.facet_fields[@facet.name]
  end

  ##
  # Splits the facet's items into two sets, one to be shown, the other hidden
  #
  # All currently selected facet items will be shown, regardless of the value of
  # the `count` parameter.
  #
  # After all selected facet items, other non-selected facet items will be
  # included in the set to show, up to a maximum set by the `count` parameter.
  #
  # All other items will be in the hidden set.
  #
  # @param count [Fixnum] Maximum number of items to be shown
  # @return [Array<Array>] Two arrays of facet items, first to show, last to hide
  def split_items(count)
    unhidden_items = []
    hidden_items = @facet.items.dup
    hidden_items.select { |item| facet_in_params?(@facet.name, item) }.each do |selected_item|
      unhidden_items << hidden_items.delete(selected_item)
    end
    while (unhidden_items.size) < count && hidden_items.present?
      unhidden_items.push(hidden_items.shift)
    end
    [unhidden_items, hidden_items]
  end

  private

  ##
  # Sends missing method calls to the controller
  def method_missing(method, *args)
    @controller.send(method, *args)
  end
end
