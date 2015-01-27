module RenderConstraintsHelper
  include Blacklight::RenderConstraintsHelperBehavior
  
  # Based on Blacklight::RenderConstraintsHelperBehavior#render_constraints_query
  # but removed :action => :index param from remove link
  def render_constraints_query(localized_params = params)
    # So simple don't need a view template, we can just do it here.
    scope = localized_params.delete(:route_set) || self
    return "".html_safe if localized_params[:q].blank?

    render_constraint_element(constraint_query_label(localized_params),
          localized_params[:q],
          :classes => ["query"],
          :remove => scope.url_for(localized_params.merge(:q=>nil)))
  end
end
