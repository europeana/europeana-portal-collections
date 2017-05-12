# frozen_string_literal: true
module Collections
  class Ugc < ApplicationView
    include BrowsableView
    include CollectionUsingView
    include SearchableView
    include UgcLinkDisplayingView

    def js_vars
      [
        {
          name: 'pageName', value: 'e7a_1418'
        }
      ]
    end

    def page_content_heading
      @collection.landing_page.title || 'First World War'
    end

    def content
      mustache[:content] ||= begin
        super
      end
    end
  end
end
