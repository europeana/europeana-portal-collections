# frozen_string_literal: true
# ##
# For views needing to display facet type entry points
module FacetEntryPointDisplayingView
  extend ActiveSupport::Concern

  protected

  def facet_entry_items(facet_link_group, page = nil)
    facet_link_group.browse_entry_facet_entries.map do |entry_point|
      thumb_url = Rails.cache.fetch("facet_link_groups/#{facet_link_group.id}/#{entry_point.id}/thumbnail_url")
      facet_entry_item(entry_point, thumb_url, page)
    end
  end

  def facet_entry_item(entry, thumb_url = nil, page = nil)
    {
      url: browse_entry_path(entry, page),
      label: entry.title,
      image_url: thumb_url,
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
  def facet_entry_items_grouped(page)
    facet_link_groups = page.facet_link_groups
    grouped_items = {}

    facet_link_groups.each do |facet_link_group|
      facet_field = facet_link_group.facet_field
      grouped_items[facet_field.parameterize.underscore.to_sym] ||= { title: facet_entry_field_title(facet_link_group), items: [] }
      grouped_items[facet_field.parameterize.underscore.to_sym][:items] = facet_entry_items(facet_link_group, page)
    end
    grouped_items.values
  end

  def facet_entry_field_title(facet_link_group)
    ff = Europeana::Blacklight::Response::Facets::FacetField.new(facet_link_group.facet_field, [])
    presenter = FacetPresenter.build(ff, controller)
    presenter.facet_title || facet_link_group.facet_field
  end
end
