module Facet
  ##
  # Handles facet field and facet item labelling
  #
  # @example Usage
  #   included do
  #     label_facet 'FACET_NAME', hash_of_labelling_options
  #   end
  # @example Labelling options
  #   {
  #     title: nil, # prevent facet from having a label
  #     items: { # item labelling options
  #       with: lambda { |item| item.sub('-', ' ') }, # custom item labelling proc
  #       titleize: true, # `titleize` item label if `true` (default `false`)
  #       i18n: true # look up item label with `I18n` if `true` (default `false`)
  #     },
  #     collapsible: { # if present, makes the facet collapsible
  #       show: 'facet.field.show', # `I18n` key for the "show" link
  #       hide: 'facet.field.hide' # `I18n` key for the "hide" link
  #     },
  #     tooltip: lambda { |controller| # custom proc for tooltip generation
  #       { # hash passed to Mustache template
  #         icon: 'icon-help', # tooltip icon
  #         link_url: controller.static_page_path('rights') # tooltip icon link
  #       }
  #     }
  #   }
  module Labelling
    extend ActiveSupport::Concern

    included do
      label_facet 'COLLECTION',
                  items: {
                    with: lambda { |item| Collection.find_by_key(item).title }
                  }
      label_facet 'TYPE', items: { titleize: true, i18n: true }
      label_facet 'IMAGE_COLOUR', items: { titleize: true, i18n: true }
      label_facet 'IMAGE_ASPECTRATIO', items: { titleize: true, i18n: true }
      label_facet 'IMAGE_SIZE', items: { i18n: true }
      label_facet 'SOUND_DURATION', items: { titleize: true, i18n: true }
      label_facet 'SOUND_HQ', items: { titleize: true, i18n: true }
      label_facet 'TEXT_FULLTEXT', items: { titleize: true, i18n: true }
      label_facet 'VIDEO_DURATION', items: { titleize: true, i18n: true }
      label_facet 'VIDEO_HD', items: { titleize: true, i18n: true }
      label_facet 'MIME_TYPE',
                  items: {
                    with: lambda do |item|
                      case item
                      when 'text/plain'
                        'TXT'
                      when 'video/x-msvideo'
                        'AVI'
                      else
                        subtype = item.split('/')[1] || ''
                        subtype.split('-').last.upcase
                      end
                    end
                  }
      label_facet 'MEDIA', items: { titleize: true, i18n: true }
      label_facet 'REUSABILITY',
                  collapsible: {
                    show: 'global.facet.license.show-specific',
                    hide: 'global.facet.license.hide-specific'
                  },
                  items: { i18n: true },
                  tooltip: lambda { |controller|
                    {
                      icon: 'icon-help',
                      link_url: controller.static_page_path('rights', format: 'html')
                    }
                  }
      label_facet 'RIGHTS',
                  title: nil,
                  items: {
                    with: lambda { |item| EDM::Rights.for_api_query(item).label }
                  }
      label_facet 'COUNTRY',
                  items: {
                    with: lambda { |item| item.dup.gsub(/\s+/, '') },
                    titleize: true, i18n: true
                  }
      label_facet 'LANGUAGE', items: { titleize: true, i18n: true }
      label_facet 'CREATOR',
                  i18n: 'fashion.designer',
                  items: {
                    with: lambda { |item| item.sub(/ \(Designer\)\z/, '') }
                  }
      label_facet 'proxy_dc_format.en',
                  i18n: 'fashion.technique',
                  items: {
                    with: lambda { |item| item.sub(/\ATechnique: /, '') },
                    titleize: true
                  }
      label_facet 'proxy_dc_type.en',
                  i18n: 'fashion.type',
                  items: {
                    with: lambda { |item| item.sub(/\AObject Type: /, '') },
                    titleize: true
                  }
      label_facet 'colour',
                  i18n: 'fashion.colour',
                  items: {
                    with: lambda { |item| item.sub(/\AColor: /, '') },
                    titleize: true
                  }
    end

    class_methods do
      def labellers
        @@labellers ||= {}
      end

      def labeller_for(field)
        labellers[field] || {}
      end

      def label_facet(field, options)
        labellers[field] = options
      end
    end

    ##
    # Label to display for a facet item
    #
    # @param value [String] Facet item value
    # @return [String] Facet item label
    def facet_item_label(value)
      if labeller[:items] && labeller[:items][:with]
        value = labeller[:items][:with].call(value)
      end

      if labeller[:items] && labeller[:items][:i18n]
        scope = labeller[:items][:i18n].is_a?(String) ? labeller[:items][:i18n] : "global.facet.#{facet_name.downcase}"
        value = t(value.downcase, scope: scope)
      end

      if labeller[:items] && labeller[:items][:titleize]
        value = value.titleize
      end

      value.present? ? value : false
    end

    ##
    # Label to display for the facet field
    #
    # @return [String]
    def facet_label
      return false if labeller.key?(:title) && labeller[:title].blank?

      key = labeller[:i18n].present? ? labeller[:i18n] : facet_name.downcase
      t(key, scope: 'global.facet.header')
    end

    ##
    # Tooltip to display for the facet field (if any)
    #
    # @return [Hash]
    def facet_tooltip
      labeller[:tooltip].call(@controller) if labeller[:tooltip]
    end

    ##
    # Labelling options for this facet field
    #
    # As declared by the `.label_facet` calls
    #
    # @return [Hash]
    def labeller
      @labeller ||= self.class.labeller_for(facet_name)
    end
  end
end
