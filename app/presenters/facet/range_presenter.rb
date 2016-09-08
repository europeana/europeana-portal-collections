module Facet
  class RangePresenter < FacetPresenter
    include Blacklight::HashAsHiddenFieldsHelperBehavior

    def display(**_)
      {
        date: true,
        title: facet_label,
        form: display_form,
        range: display_range,
        data: display_data,
        date_start: range_min,
        date_end: range_max,
        show_bars: range_min != range_max
      }
    end

    ##
    # Maximum number of hits in any of the facet items
    #
    # @return [Fixnum]
    def hits_max
      @hits_max ||= items_to_display.map(&:hits).max
    end

    ##
    # Lowest value in the range
    #
    # @return [Object]
    def range_min
      @range_min ||= items_to_display.map(&:value).min
    end

    ##
    # Highest value in the range
    #
    # @return [Object]
    def range_max
      @range_max ||= items_to_display.map(&:value).max
    end

    def apply_split_to_items?
      false
    end

    protected

    def items_to_display(*_)
      @items_to_display ||= super
    end

    def display_data
      items_to_display.sort_by(&:value).map do |item|
        p = search_state.params_for_search.deep_dup
        p[:f] ||= {}
        p[:f][@facet.name] = [item.value]
        {
          percent_of_max: (item.hits.to_f / hits_max.to_f * 100).to_i,
          value: "#{item.value} (#{item.hits})",
          url: search_action_url(p)
        }
      end
    end

    def display_range
      {
        start: {
          input_name: "range[#{@facet.name}][begin]",
          input_value: display_range_start,
          label_text: 'From:'
        },
        end: {
          input_name: "range[#{@facet.name}][end]",
          input_value: display_range_end,
          label_text: 'To:'
        }
      }
    end

    def display_range_start
      if range_min == range_max
        range_min
      elsif search_state.params_for_search[:range] && search_state.params_for_search[:range][@facet.name]
        search_state.params_for_search[:range][@facet.name][:begin]
      else
        range_min
      end
    end

    def display_range_end
      if range_min == range_max
        range_min
      elsif search_state.params_for_search[:range] && search_state.params_for_search[:range][@facet.name]
        search_state.params_for_search[:range][@facet.name][:end]
      else
        range_max
      end
    end

    def display_form
      {
        action_url: search_action_url,
        hidden_inputs: hidden_inputs_for_search
      }
    end

    def hidden_inputs_for_search
      flatten_hash(search_state.params_for_search.except(:page, :utf8, :range, :locale)).map do |name, value|
        [value].flatten.map { |v| { name: name, value: v.to_s } }
      end.flatten
    end
  end
end
