module Facet
  class RangePresenter < FacetPresenter
    include Blacklight::HashAsHiddenFieldsHelperBehavior

    class DisplayableRangeItem < Struct.new(:percent_of_max, :value, :min_value, :max_value, :hits, :url)
      def initialize(percent_of_max = 0, value = nil, min_value = nil, max_value = nil, hits = 0, url = false); super end
    end

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
        show_bars: !single_value?,
        show_borders: display_data.length < 50
      }
    end

    def filter_item(_)
      fail NotImplementedError
    end

    def items_in_params
      fail NotImplementedError
    end

    def facet_item_url(_)
      fail NotImplementedError
    end

    def filter_items
      return [] unless range_in_params?
      [
        {
          filter: facet_label,
          value: display_range_value,
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
    # Maximum number of hits in any of the facet items - constrained to the selection
    #
    # @return [Fixnum]
    def hits_max
      @hits_max ||= items_to_display.map do |item|
        if item.value.to_i < range_min || item.value.to_i > range_max
          0
        else
          item.hits
        end
      end.max
    end

    ##
    # Lowest value in the range - confined to begin parameter
    #
    # @return [Object]
    def range_min
      @range_min ||= has_begin ? search_state_param[:begin].to_i : range_values.min
    end

    ##
    # Highest value in the range - confined to end parameter
    #
    # @return [Object]
    def range_max
      @range_max ||= has_end ? search_state_param[:end].to_i : range_values.max
    end

    def range_values
      @range_values ||= items_to_display.map{ |item| item.value.to_i }
    end

    def range_middle
      @range_middle ||= begin
        if !range_min.is_a?(Fixnum) || !range_max.is_a?(Fixnum)
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


    ##
    # Loops through the available facets and generates the facet links and display values for each item in the range.
    #
    def display_data
      @display_data ||= aggregated_items.map do |item|
        p = search_state.params_for_search.deep_dup
        p[:range] ||= {}
        p[:range][facet_name] ||= {}
        p[:range][facet_name][:begin] = item.min_value
        p[:range][facet_name][:end] = item.max_value

        display_value = item.min_value == item.max_value ? item.value : "#{item.min_value} - #{item.max_value}"
        tooltip_text = "#{display_value} (#{item.hits})"

        {
          percent_of_max: percent_of_max(item.hits),
          value: tooltip_text,
          hits: item.hits,
          url: search_action_url(p)
        }
      end
    end

    ##
    # A method to aggregate facets into segments. The maximum number of ranges to facet on
    # will be determined by the max_intervals method. This is to avoid filling the graph with too many
    # bars.
    #
    def aggregated_items
      items = limited_items
      if items.count > max_intervals && ((items.count / max_intervals) != 1)
        aggregated_items = []
        interval = items.count / max_intervals
        temp_item = DisplayableRangeItem.new()
        items.each_with_index do | item, index |
          if (index + 1) % interval != 0
            temp_item.hits += item.hits
            temp_item.min_value = item.value unless temp_item.min_value
          else
            temp_item.max_value = item.value
            aggregated_items << temp_item
            temp_item = DisplayableRangeItem.new()
          end
        end
        @hits_max = aggregated_items.max_by{|x| x[:hits]}.hits
        aggregated_items
      else
        items
      end
    end

    ##
    # A method to limit the range of facet items to display to the range specified by the user.
    #
    def limited_items
      padded_items.map do |item|
        skip = false

        if has_begin && item.value.to_i < search_state_param[:begin].to_i
          skip = true
        end
        if has_end && item.value.to_i > search_state_param[:end].to_i
          skip = true
        end

        skip ? nil : item
      end
    end

    ##
    # Method to fill in gaps in the facet range values with empty values.
    #
    def padded_items
      items = items_to_display
      return_hash = []
      items.sort!{ |a, b| a.value.to_i <=> b.value.to_i } unless has_begin && has_end
      begin_value = (has_begin ? search_state_param[:begin] : items.first[:value]).to_i
      end_value = (has_end ? search_state_param[:end] : items.last[:value]).to_i
      (begin_value..end_value).each do |item_value|
        item_to_add = items.select {|i| i.value == item_value.to_s}.first
        item_to_add ||= DisplayableRangeItem.new(0, item_value,item_value,item_value, 0, false)
        return_hash << item_to_add
      end
      return_hash
    end

    def max_intervals
      100
    end

    ##
    # returns boolean for whether or not there is a start value specified to facet on
    #
    def has_begin
      @has_begin = search_state_param && search_state_param[:begin]
    end

    ##
    # returns boolean for whether or not there is an end value specified to facet on
    #
    def has_end
      @has_end = search_state_param && search_state_param[:end]
    end

    def percent_of_max(hits)
      if hits_max.to_f > 0
        (hits.to_f / hits_max.to_f * 100).to_i
      else
        0
      end
    end

    def display_range
      {
        start: {
          input_name: "range[#{facet_name}][begin]",
          input_value: display_range_start,
          label_text: 'From:'
        },
        end: {
          input_name: "range[#{facet_name}][end]",
          input_value: display_range_end,
          label_text: 'To:'
        }
      }
    end

    def display_range_value
      single_value? ? display_range_start : "#{display_range_start}–#{display_range_end}"
    end

    def single_value?
      display_range_start == display_range_end
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
