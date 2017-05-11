# frozen_string_literal: true
module Collections
  class Ugc < ApplicationView
    include BrowsableView
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
        {
          # TODO: Add additional elements here, or just return super
        }.reverse_merge(super)
      end
    end

    def collection_data
      mustache[:collection_data] ||= begin
        {
          label: @collection.landing_page.title,
          url: collection_url(@collection)
        }
      end
    end
    alias_method :channel_data, :collection_data
  end
end
