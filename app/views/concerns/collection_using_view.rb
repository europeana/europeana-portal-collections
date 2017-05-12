# frozen_string_literal: true
# ##
# For views needing to display information related to a specific collection.
module CollectionUsingView
  extend ActiveSupport::Concern

  def collection_data
    mustache[:collection_data] ||= begin
      if @collection
        {
          name: @collection.key,
          label: @collection.landing_page ? @collection.landing_page.title : @collection.title,
          url: collection_url(@collection),
          def_view: @collection.settings['default_search_layout']
        }
      end
    end
  end
  alias_method :channel_data, :collection_data
end
