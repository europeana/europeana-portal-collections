# frozen_string_literal: true

module Portal
  class Ancestor < ApplicationView
    include SearchableView
    include ThumbnailHelper

    # TODO: remove when js_var_page_name observation implemented by
    #   https://github.com/europeana/europeana-portal-collections/pull/1100
    def js_vars
      super.tap do |vars|
        page_name_var = vars.detect { |var| var[:name] == 'pageName' }
        page_name_var[:value] = js_var_page_name
      end
    end

    def js_var_page_name
      'entities/show'
    end

    def bodyclass
      'channel_entity'
    end

    def page_content_heading
      presenter.title
    end

    def include_nav_searchbar
      true
    end

    def content
      mustache[:content] ||= begin
        {
          tab_items: tab_items,
          entity_anagraphical: anagraphical,
          entity_thumbnail: thumbnail,
          entity_description: presenter.field_value('proxies.dcDescription'),
          entity_title: presenter.title,
          input_search: input_search
        }
      end
    end

    protected

    def tab_items
      [
        {
          tab_title: t('site.object.meta-label.consists-of'),
          url: descendent_search_url(format: 'json'),
          search_url: descendent_search_url
        }
      ]
    end

    def descendent_search_url(**options)
      options.merge!(
        q: %(proxy_dcterms_isPartOf:"http://data.europeana.eu/item#{document.id}"),
        sort: 'europeana_id asc'
      )
      search_url(options)
    end

    def anagraphical
      [
        {
          label: t('site.object.meta-label.issued'),
          value: presenter.field_value('proxies.dctermsIssued')
        }
      ]
    end

    def thumbnail
      @thumbnail ||= {
        src: thumbnail_url_for_edm_preview(presenter.field_value('europeanaAggregation.edmPreview'), size: '400')
      }
    end

    def presenter
      @presenter ||= Document::RecordPresenter.new(document, controller)
    end
  end
end
