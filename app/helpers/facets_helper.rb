##
# BL facets helper
module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  def facet_in_params?(field, item)
    value = facet_value_for_facet_item(item)
    super || (field =='CHANNEL' && within_channel? && (params[:id] == value))
  end
end
