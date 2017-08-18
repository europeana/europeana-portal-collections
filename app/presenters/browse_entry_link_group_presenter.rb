# frozen_string_literal: true
##
# Display logic for browse entry point groups.
#
# Responsible for generating data hashes for the Mustache templates from
# [Europeana's styleguide](https://github.com/europeana/europeana-styleguide-ruby)
# to display browse entry points on browse based landing pages.
class BrowseEntryGroupPresenter
  include UrlHelper
  delegate :t, to: I18n

  attr_reader :controller, :facet_link_group

  def initialize(browse_entry_group, controller, page = nil)
    @browse_entry_group = browse_entry_group
    @controller = controller
    @page = page
  end

  def display
    {
      title: @browse_entry_group.title,
      items: custom_browse_entry_items,
      position: @browse_entry_group.position
    }
  end

  def custom_browse_entry_items
    @browse_entry_group.browse_entry_entries.map do |entry_point|
      custom_browse_entry_item(entry_point)
    end.order_by(position)
  end

  def custom_browse_entry_item(entry, page = nil)
    {
      url: browse_entry_path(entry, page),
      label: entry.title,
      value: entry.query,
      image: entry.file.nil? ? nil : entry.file.url,
      image_alt: nil,
      position: entry.position
    }
  end

  def respond_to_missing?(method_name, include_private = false)
    controller.respond_to?(method_name) || super
  end

  ##
  # Sends missing method calls to the controller
  def method_missing(method, *args)
    if controller.respond_to?(method)
      controller.send(method, *args)
    else
      super
    end
  end
end
