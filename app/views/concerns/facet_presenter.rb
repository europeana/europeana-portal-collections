module FacetPresenter
  extend ActiveSupport::Concern

  protected

  def facet_item_url(facet, item)
    if facet_in_params?(facet, item)
      search_action_url(remove_facet_params(facet, item, params))
    else
      search_action_url(add_facet_params_and_redirect(facet, item))
    end
  end

  def facet_display(facet, children = false)
    facet_config = blacklight_config.facet_fields[facet.name]
    if facet_config.colour
      colour_facet(facet)
    elsif facet_config.range
      range_facet(facet)
    elsif facet_config.hierarchical && !facet_config.parent
      hierarchical_facet(facet)
    else
      simple_facet(facet)
    end
  end

  def basic_facet(facet, type = :simple)
    facet_config = blacklight_config.facet_fields[facet.name]
    {
      title: facet_map(facet.name),
      select_one: facet_config.single,
      items: facet.items[0..3].map { |item| send(:"#{type}_facet_item", facet, item) },
      extra_items: facet.items.size <= 4 ? nil : {
        items: facet.items[4..-1].map { |item| send(:"#{type}_facet_item", facet, item) }
      }
    }.merge(type => true)
  end

  def basic_facet_item(facet, item)
    {
      url: facet_item_url(facet.name, item),
      text: facet_map(facet.name, item.value),
      num_results: number_with_delimiter(item.hits),
      is_checked: facet_in_params?(facet.name, item)
    }
  end

  def simple_facet(facet)
    basic_facet(facet, type = :simple)
  end

  def simple_facet_item(facet, item)
    basic_facet_item(facet, item)
  end

  def colour_facet(facet)
    basic_facet(facet, type = :colour)
  end

  def colour_facet_item(facet, item)
    basic_facet_item(facet, item).tap do |basic|
      basic.delete(:text)
      basic[:hex] = item.value
    end
  end

  def hierarchical_facet(facet)
    basic_facet(facet, type = :hierarchical)
  end

  def hierarchical_facet_item(facet, item)
    child_facets = hierarchical_facet_item_children(facet, item)

    {
      has_subfilters: child_facets.present?,
      filters: child_facets.map { |child| facet_display(child, true) }
    }.merge(simple_facet_item(facet, item))
  end

  def hierarchical_facet_item_children(facet, item)
    facets_from_request(facet_field_names).select do |child|
      parent = blacklight_config.facet_fields[child.name].parent
      !parent.nil? && (parent.first == facet.name) && (parent.last == item.value)
    end
  end

  def range_facet(facet)
    range_min = facet.items.collect(&:value).min
    range_max = facet.items.collect(&:value).max
    hits_max = facet.items.collect(&:hits).max
    {
      date: true,
      title: facet_map(facet.name),
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
      data: facet.items.sort_by(&:value).collect do |item|
        p = reset_search_params(params).deep_dup
        p[:f] ||= {}
        p[:f][facet.name] = [item.value]
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
end
