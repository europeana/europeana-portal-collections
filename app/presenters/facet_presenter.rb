##
# Display logic for facets
class FacetPresenter
  include FacetsHelper
  include UrlHelper
  include ActionView::Helpers::NumberHelper
  delegate :t, to: I18n

  def initialize(facet, controller, configuration = controller.blacklight_config)
    @facet = facet
    @configuration = configuration
    @controller = controller
    @response = controller.instance_variable_get(:@response)
  end

  def display(show_children = false)
    if facet_config.hierarchical && !facet_config.parent
      hierarchical_facet
    elsif !facet_config.parent || show_children
      if facet_config.boolean
        boolean_facet
      elsif facet_config.colour
        colour_facet
      elsif facet_config.range
        range_facet
      else
        simple_facet
      end
    end
  end

  def facet_item_url(item)
    if facet_in_params?(@facet.name, item)
      search_action_url(remove_facet_params(@facet.name, item, @controller.params))
    else
      search_action_url(add_facet_params_and_redirect(@facet.name, item))
    end
  end

  def facet_config
    @facet_config ||= @configuration.facet_fields[@facet.name]
  end

  def basic_facet(options = {})
    options = options.reverse_merge(type: :simple, count: 4)
    unhidden_items, hidden_items = split_items(options[:count])
    {
      title: facet_label(@facet.name),
      select_one: facet_config.single,
      items: unhidden_items.map { |item| send(:"#{options[:type]}_facet_item", item) },
      extra_items: hidden_items.blank? ? nil : {
        items: hidden_items.map { |item| send(:"#{options[:type]}_facet_item", item) }
      }
    }.merge(options[:type] => true)
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

  def basic_facet_item(item)
    {
      url: facet_item_url(item),
      text: facet_label(@facet.name, item.value),
      num_results: number_with_delimiter(item.hits),
      is_checked: facet_in_params?(@facet.name, item)
    }
  end

  def simple_facet
    basic_facet(type: :simple)
  end

  def simple_facet_item(item)
    basic_facet_item(item)
  end

  def colour_facet
    basic_facet(type: :colour)
  end

  def colour_facet_item(item)
    basic_facet_item(item).tap do |basic|
      basic.delete(:text)
      basic[:hex] = item.value
    end
  end

  def hierarchical_facet
    basic_facet(type: :hierarchical)
  end

  def hierarchical_facet_item(item)
    child_facets = hierarchical_facet_item_children(item)

    {
      has_subfilters: child_facets.present?,
      filters: child_facets.map do |child|
        self.class.new(child, @controller).display(true)
      end
    }.merge(simple_facet_item(item))
  end

  def hierarchical_facet_item_children(item)
    facets_from_request(facet_field_names).select do |child|
      parent = @configuration.facet_fields[child.name].parent
      if parent.is_a?(Array)
        (parent.first == @facet.name) && (parent.last == item.value)
      elsif !parent.nil?
        parent == @facet.name
      end
    end
  end

  def range_facet
    range_min = @facet.items.map(&:value).min
    range_max = @facet.items.map(&:value).max
    hits_max = @facet.items.map(&:hits).max
    {
      date: true,
      title: facet_label(@facet.name),
      form: {
        action_url: search_action_url,
        hidden_inputs: hidden_inputs_for_search
      },
      range: {
        start: {
          input_name: "range[#{facet.name}][begin]",
          input_value: range_min,
          label_text: 'From:'
        },
        end: {
          input_name: "range[#{facet.name}][end]",
          input_value: range_max,
          label_text: 'To:'
        }
      },
      data: @facet.items.sort_by(&:value).map do |item|
        p = reset_search_params(params).deep_dup
        p[:f] ||= {}
        p[:f][@facet.name] = [item.value]
        {
          percent_of_max: (item.hits.to_f / hits_max.to_f * 100).to_i,
          value: "#{item.value} (#{item.hits})",
          url: search_action_path(p)
        }
      end,
      date_start: range_min,
      date_end: range_max
    }
  end

  def boolean_facet
    {
      url: boolean_facet_url,
      text: facet_label(@facet.name),
      is_checked: boolean_facet_checked?,
      boolean: true
    }
  end

  def boolean_facet_url
    if boolean_facet_in_params?(@facet.name)
      search_action_url(remove_facet_params(@facet.name, facet_params(@facet.name).first, params))
    elsif boolean_facet_checked?
      search_action_url(add_facet_params_and_redirect(@facet.name, facet_config.boolean[:off]))
    else
      search_action_url(add_facet_params_and_redirect(@facet.name, facet_config.boolean[:on]))
    end
  end

  def boolean_facet_checked?
    if facet_config.boolean[:on].nil? && !boolean_facet_in_params?(@facet.name)
      true
    elsif !facet_config.boolean[:on].nil? && facet_in_params?(@facet.name, facet_config.boolean[:on])
      true
    else
      facet_config.boolean[:default] == :on
    end
  end

  def boolean_facet_in_params?(field)
    (facet_params(field) || []).present?
  end

  private

  def method_missing(method, *args)
    @controller.send(method, *args)
  end
end
