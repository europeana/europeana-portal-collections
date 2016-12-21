# frozen_string_literal: true
# ##
# For views needing to display facet type entry points
module FacetEntryPointDisplayingView
  extend ActiveSupport::Concern

  protected

  def facet_entry_item(entry, page = nil)
    {
      url: browse_entry_path(entry, page),
      label: entry.title,
      image_url: entry.file.nil? ? nil : entry.file.url,
      image_alt: nil
    }
    # Use this model to behave more like normal browse entries,
    # however this needs frontend alignment.
    # {
    #     title: entry.title,
    #     url: browse_entry_path(entry, page),
    #     image: entry.file.nil? ? nil : entry.file.url,
    #     image_alt: nil
    # }
  end

  ##
  # @param page [Page]
  def facet_entry_items_grouped(browse_entries, page = nil)
    grouped_items = {}

    browse_entries.each do |entry|
      facet_field = entry.facet_field
      grouped_items[facet_field.parameterize.underscore.to_sym] ||= { title: facet_field, items: [] }
      grouped_items[facet_field.parameterize.underscore.to_sym][:items] << facet_entry_item(entry, page)
    end
    grouped_items.values
  end
end
