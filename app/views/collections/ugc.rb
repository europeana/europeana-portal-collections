# frozen_string_literal: true
module Collections
  class Ugc < ApplicationView
    include BrowsableView
    include SearchableView

    def js_vars
      [
        {
          name: 'pageName', value: 'e7a_1418'
        }
      ]
    end

    def page_content_heading
      if Collection.find_by_key('firstworldwar').present?
        Collection.find_by_key('firstworldwar').title
      else
        'First World War'
      end
    end

    def content
      {
        base_1418_url: config.x.europeana_1914_1918_url,
      }
    end

    def collection_data
      mustache[:collection_data] ||= begin
        collection = @collection
        {
          label: collection.landing_page.title,
          url: collection_url(collection)
        }
      end
    end
    alias_method :channel_data, :collection_data
  end
end
