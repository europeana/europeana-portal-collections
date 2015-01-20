module SearchHistoryConstraintsHelper
  include Blacklight::SearchHistoryConstraintsHelperBehavior
  
  def render_search_to_s(params)
    render_search_to_s_channel(params) +
    render_search_to_s_q(params) +
    render_search_to_s_filters(params)
  end
  
  # @todo Don't hardcode "Channel" label
  def render_search_to_s_channel(params)
    return "".html_safe unless params['controller'] == 'channels' and params['action'] == 'show' and params['id'].present?
    
    label = "Channel"
    
    render_search_to_s_element(label , render_filter_value(params['id']) )
  end
end
