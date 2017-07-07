##
# For views needing to display `BrowseEntry` objects
#
# TODO: refactor into a browse entry presenter
module BrowseEntryDisplayingView
  extend ActiveSupport::Concern

  protected

  def browse_entry_item(entry, page = nil)
    {
      title: entry.title,
      url: browse_entry_path(entry, page),
      image: entry.file.nil? ? nil : entry.file.url,
      image_alt: nil
    }
  end

  def browse_entry_items(browse_entries, page = nil)
    browse_entries.map do |entry|
      browse_entry_item(entry, page)
    end
  end

  def browse_entry_items_grouped(page)
    return nil if page.browse_entry_groups.blank?

    {
      grouped_items: page.browse_entry_groups.map { |group| browse_entry_item_group(group, page) },
      is_single_type: page.browse_entry_groups.count == 1
    }
  end

  # @param group [PageElementGroup] group of browse entries as page elements
  # @param page [Page] page the elements are to be displayed on
  def browse_entry_item_group(group, page = nil)
    return unless group.browse_entries.present?

    subject_type = group.browse_entries.first.subject_type
    {
      more_link: browse_entry_more_link_path(subject_type),
      more_text: browse_entry_more_link_text(subject_type),
      items: group.browse_entries.map { |entry| browse_entry_item(entry, page) }
    }
  end

  def browse_entry_more_link_path(subject_type)
    send(:"explore_#{subject_type.pluralize}_path", theme: collection.key)
  end

  def browse_entry_more_link_text(subject_type)
    t(subject_type.pluralize, scope: 'global.navigation.more')
  end
end
