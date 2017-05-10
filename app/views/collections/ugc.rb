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
        portal_url: home_url
      }
    end
  end
end
