##
# For views needing to display `BrowseEntry` objects
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

  def browse_entry_items_grouped(browse_entries, page = nil)
    browse_entries_grouped = browse_entries.group_by(&:subject_type)

    ordered_items = [
      browse_entry_item_group('person', browse_entries_grouped['person'], page),
      browse_entry_item_group('topic', browse_entries_grouped['topic'], page),
      browse_entry_item_group('period', browse_entries_grouped['period'], page)
    ].compact

    {
      grouped_items: ordered_items,
      is_single_type: browse_entries_grouped.count == 1
    }
  end

  def browse_entry_item_group(subject_type, entries, page = nil)
    return unless entries.present?
    {
      more_link: browse_entry_more_link_path(subject_type),
      more_text: browse_entry_more_link_text(subject_type),
      items: entries.map { |entry| browse_entry_item(entry, page) }
    }
  end

  def browse_entry_more_link_path(subject_type)
    send(:"explore_#{subject_type.pluralize}_path", theme: collection.key)
  end

  def browse_entry_more_link_text(subject_type)
    t(subject_type.pluralize, scope: 'global.navigation.more')
  end
end
