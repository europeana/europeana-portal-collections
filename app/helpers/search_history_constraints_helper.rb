##
# Search history constraints helper
#
# @see Blacklight::SearchHistoryConstraintsHelperBehavior
module SearchHistoryConstraintsHelper
  include Blacklight::SearchHistoryConstraintsHelperBehavior

  def render_search_to_s(params)
    render_search_to_s_collection(params) +
      render_search_to_s_q(params) +
      render_search_to_s_filters(params)
  end

  # @todo Don't hardcode "Collection" label
  def render_search_to_s_collection(params)
    return ''.html_safe unless within_collection?(params)

    label = 'Collection'
    render_search_to_s_element(label, render_filter_value(params[:id]))
  end
end
