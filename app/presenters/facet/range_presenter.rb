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
        date_middle: range_middle,
        date_end: range_max,
        show_bars: !single_value?
      }
    end

    def filter_item(item)
      fail NotImplementedError
    end

    def items_in_params
      fail NotImplementedError
    end

    def facet_item_url(item)
      fail NotImplementedError
    end

    def filter_items
      return [] unless range_in_params?
      [
        {
          filter: facet_label,
          value: "#{display_range_start}–#{display_range_end}",
          remove: search_action_url(remove_link_params),
          name: "range[#{facet_name}][]"
        }
      ]
    end

    def remove_link_params
      p = search_state.params_for_search.deep_dup
      p[:range] = (p[:range] || {}).dup
      p[:range].delete(facet_config.key)
      p.delete(:range) if p[:range].empty?
      p
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
      @range_min ||= range_values.min
    end

    ##
    # Highest value in the range
    #
    # @return [Object]
    def range_max
      @range_max ||= range_values.max
    end

    def range_values
      @range_values ||= items_to_display.map(&:value)
    end

    def range_middle
      @range_middle ||= begin
        if !range_min.is_a?(Fixnum) || !range_max.is_a?
          nil
        else
          (range_min + range_max) / 2
        end
      end
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

    def single_value?
      range_min == range_max
    end

    def search_state_param
      @search_state_param ||= begin
        range_in_params? ? search_state.params_for_search[:range][facet_name] : nil
      end
    end

    def range_in_params?
      search_state.params_for_search[:range] && search_state.params_for_search[:range][facet_name]
    end

    def display_range_start
      search_state_param.present? ? search_state_param[:begin] : range_min
    end

    def display_range_end
      search_state_param.present? ? search_state_param[:end] : range_max
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
