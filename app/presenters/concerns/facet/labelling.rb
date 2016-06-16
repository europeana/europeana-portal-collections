module Facet
  module Labelling
    extend ActiveSupport::Concern

    included do
      label_facet 'COLLECTION',
                  items: {
                      with: lambda { |item| Collection.find_by_key(item).title || I18n.t('global.channel.all') }
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
                  items: { titleize: true, i18n: true },
                  tooltip: lambda { |controller|
                    {
                      icon: 'icon-help',
                      link_url: controller.static_page_path('rights', format: 'html')
                    }
                  }
      label_facet 'RIGHTS',
                  title: nil,
                  items: {
                    with: lambda do |item|
                      EDM::Rights.registry.detect { |rights| rights.api_query == item }.label
                    end
                  }
      label_facet 'COUNTRY',
                  items: {
                    with: lambda { |item| item.dup.gsub(/\s+/, '') },
                    titleize: true, i18n: true
                  }
      label_facet 'LANGUAGE', items: { titleize: true, i18n: true }
      label_facet 'CREATOR',
                  i18n: 'designer',
                  items: {
                    with: lambda { |item| item.sub(/ \(Designer\)\z/, '') }
                  }
      label_facet 'proxy_dc_format.en',
                  i18n: 'technique',
                  items: {
                    with: lambda { |item| item.sub(/\ATechnique: /, '') },
                    titleize: true
                  }
      label_facet 'cc_skos_prefLabel.en',
                  i18n: 'item_type',
                  items: { titleize: true }
      label_facet 'colour',
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

    def labeller
      @labeller ||= self.class.labeller_for(facet_name)
    end

    ##
    # Gets a label to display for the facet field
    #
    # @return [String]
    def facet_label
      return false if labeller.key?(:title) && labeller[:title].blank?

      key = labeller[:i18n].present? ? labeller[:i18n] : facet_name.downcase
      t(key, scope: 'global.facet.header')
    end

    def facet_tooltip
      labeller[:tooltip].call(@controller) if labeller[:tooltip]
    end

    def facet_item_label(value)
      if labeller[:items] && labeller[:items][:with]
        value = labeller[:items][:with].call(value)
      end

      if labeller[:items] && labeller[:items][:i18n]
        scope = labeller[:items][:i18n].is_a?(String) ? labeller[:items][:i18n] : "global.facet.#{facet_name.downcase}"
        value = t(value.downcase, scope: scope)
      end

      if labeller[:items] && labeller[:items][:titleize]
        value = value.split.map(&:capitalize).join(' ')
      end

      value.present? ? value : false
    end
  end
end
