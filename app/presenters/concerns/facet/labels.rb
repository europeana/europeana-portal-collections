module Facet
  module Labels
    extend ActiveSupport::Concern

    ##
    # Gets a label to display for the facet field
    #
    # @return [String]
    def facet_label
      t('global.facet.header.' + @facet.name.downcase)
    end

    def facet_item_label(facet_item)
      facet_item = facet_item.dup.gsub(/\s+/, '') if @facet.name == 'COUNTRY'

      mapped_value = case @facet.name.upcase
                     when 'PROVIDER', 'DATA_PROVIDER', 'COLOURPALETTE', 'YEAR', 'RIGHTS'
                       facet_item
                     when 'MIME_TYPE'
                       mime_type_facet_item_label(facet_item)
                     else
                       t('global.facet.' + @facet.name.downcase + '.' + facet_item.downcase)
                     end

      unless ['PROVIDER', 'DATA_PROVIDER', 'MIME_TYPE', 'IMAGE_SIZE', 'RIGHTS'].include?(@facet.name)
        mapped_value = mapped_value.titleize
      end

      mapped_value.present? ? mapped_value : false
    end

    protected

    def mime_type_facet_item_label(facet_item)
      case facet_item
      when 'text/plain'
        'TXT'
      when 'video/x-msvideo'
        'AVI'
      else
        subtype = facet_item.split('/')[1] || ''
        subtype.split('-').last.upcase
      end
    end
  end
end
