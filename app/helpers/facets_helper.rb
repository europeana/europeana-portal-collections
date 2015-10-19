##
# BL facets helper
module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  def facet_in_params?(field, item)
    value = facet_value_for_facet_item(item)
    super || (field =='CHANNEL' && within_channel? && (params[:id] == value))
  end

  def facet_label(facet_name, facet_value = nil)
    if facet_value.nil?
      t('global.facet.header.' + facet_name.downcase)
    else
      facet_value = ('COUNTRY' == facet_name ? facet_value.gsub(/\s+/, '') : facet_value)

      mapped_value = case facet_name.upcase
                     when 'CHANNEL'
                       t('global.channel.' + facet_value.downcase)
                     when 'PROVIDER', 'DATA_PROVIDER', 'COLOURPALETTE'
                       facet_value
                     else
                       t('global.facet.' + facet_name.downcase + '.' + facet_value.downcase)
                     end

      unless ['PROVIDER', 'DATA_PROVIDER', 'MIME_TYPE', 'IMAGE_SIZE'].include?(facet_name)
        mapped_value = mapped_value.split.map(&:capitalize).join(' ')
      end

      mapped_value
    end
  end

  def facet_item_url(facet, item)
    FacetPresenter.new(facet, controller).facet_item_url(item)
  end
end
