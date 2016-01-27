module Facet
  class RangePresenter < FacetPresenter
    def display(_options = {})
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
          p = Blacklight::SearchState.new(params, blacklight_config).send(:reset_search_params)
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
  end
end
