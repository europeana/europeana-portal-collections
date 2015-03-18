##
# Render constraints helpers
#
# @see Blacklight::RenderConstraintsHelperBehavior
module RenderConstraintsHelper
  include Blacklight::RenderConstraintsHelperBehavior

  def query_has_constraints?(localized_params = params)
    !(localized_params[:q].blank? && localized_params[:f].blank? &&
      localized_params[:qf].blank?)
  end

  def render_constraints(localized_params = params)
    render_constraints_query(localized_params) +
      render_constraints_filters(localized_params) +
      render_constraints_qfs(localized_params)
  end

  # Based on
  # {Blacklight::RenderConstraintsHelperBehavior#render_constraints_query}
  # but removed :action => :index param from remove link
  def render_constraints_query(localized_params = params)
    # So simple don't need a view template, we can just do it here.
    scope = localized_params.delete(:route_set) || self
    return ''.html_safe if localized_params[:q].blank?

    render_constraint_element(
      constraint_query_label(localized_params),
      localized_params[:q],
      classes: ['query'],
      remove: scope.url_for(localized_params.merge(q: nil))
    )
  end

  def render_constraints_qfs(localized_params = params)
    return ''.html_safe unless localized_params[:qf]
    content = []
    localized_params[:qf].each do |value|
      content << render_qf_element(value, localized_params)
    end

    safe_join(content.flatten, "\n")
  end

  def render_qf_element(value, localized_params)
    remove_path = search_action_path(remove_qf_param(value, localized_params))
    render_constraint_element(nil, value,
                              remove: remove_path,
                              classes: ['filter']
    )
  end
end
