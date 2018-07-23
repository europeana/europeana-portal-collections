# frozen_string_literal: true

module Portal
  # TODO: duplicates code from Entities::Show view; extract into a concern
  class Ancestor < ApplicationView
    include SearchableView
    include ThumbnailHelper

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

    # TODO: change keys to be non-entity related
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
          search_url: descendent_search_url,
          referenced_records: referenced_records
        }
      ]
    end

    def referenced_records
      {
        search_results: @search_results[:items].map { |item| result_presenter(item).content },
        total: {
          value: @search_results[:totalResults],
          formatted: number_with_delimiter(@search_results[:totalResults])
        }
      }
    end

    def result_presenter(item)
      Document::SearchResultPresenter.new(item, self)
    end

    def descendent_search_url(**options)
      options[:q] = %(proxy_dcterms_isPartOf:"http://data.europeana.eu/item#{document.id}")
      options[:sort] = 'europeana_id asc'
      search_url(options)
    end

    def anagraphical
      [
        {
          label: t('site.object.meta-label.issued'),
          value: presenter.field_value('proxies.dctermsIssued')
        }
      ].reject { |hash| hash[:value].blank? }
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
