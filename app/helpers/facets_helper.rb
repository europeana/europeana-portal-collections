##
# BL facets helper
module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  def facet_in_params?(field, item)
    value = facet_value_for_facet_item(item)
    super || (field == 'COLLECTION' && within_collection? && (params[:id] == value))
  end

  def facet_label(facet_name, facet_value = nil)
    if facet_value.nil?
      t('global.facet.header.' + facet_name.downcase)
    else
      facet_value = ('COUNTRY' == facet_name ? facet_value.gsub(/\s+/, '') : facet_value)

      mapped_value = case facet_name.upcase
                     when 'COLLECTION'
                       t('global.channel.' + facet_value.downcase)
                     when 'PROVIDER', 'DATA_PROVIDER', 'COLOURPALETTE'
                       facet_value
                     when 'MIME_TYPE'
                       case facet_value
                       when 'text/plain'
                        'TXT'
                       when 'video/x-msvideo'
                         'AVI'
                       else
                         subtype = facet_value.split('/')[1] || ''
                         subtype.split('-').last.upcase
                       end
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
