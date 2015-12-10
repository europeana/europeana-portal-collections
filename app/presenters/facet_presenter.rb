##
# Display logic for facets
class FacetPresenter
  include FacetsHelper
  include UrlHelper
  include ActionView::Helpers::NumberHelper
  delegate :t, to: I18n

  ##
  # Factory
  def self.build(facet, controller, blacklight_config = controller.blacklight_config)
    facet_config = blacklight_config.facet_fields[facet.name]
    class_for_facet(facet_config).new(facet, controller, blacklight_config)
  end

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

  def initialize(facet, controller, blacklight_config = controller.blacklight_config)
    @facet = facet
    @blacklight_config = blacklight_config
    @controller = controller
    @response = controller.instance_variable_get(:@response)
  end

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

  def facet_item(item)
    {
      url: facet_item_url(item),
      text: facet_label(@facet.name, item.value),
      num_results: number_with_delimiter(item.hits),
      is_checked: facet_in_params?(@facet.name, item)
    }
  end

  def facet_item_url(item)
    if facet_in_params?(@facet.name, item)
      search_action_url(remove_facet_params(@facet.name, item, @controller.params))
    else
      search_action_url(add_facet_params_and_redirect(@facet.name, item))
    end
  end

  def facet_config
    @facet_config ||= @blacklight_config.facet_fields[@facet.name]
  end

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

  def method_missing(method, *args)
    @controller.send(method, *args)
  end
end
