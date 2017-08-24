# frozen_string_literal: true
# ##
# For views needing to display facet type entry points
module FacetEntryPointDisplayingView
  extend ActiveSupport::Concern

  protected

  ##
  # @param page [Page]
  def facet_entry_items_grouped(page)
    page.facet_entry_groups.map do |facet_entry_group|
      FacetEntryGroupPresenter.new(facet_entry_group, controller, blacklight_config, page).display
    end
  end
end
