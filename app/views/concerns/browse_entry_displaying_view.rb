##
# For views needing to display `BrowseEntry` objects
module BrowseEntryDisplayingView
  extend ActiveSupport::Concern

  protected

  def browse_entry_item(entry, page = nil)
    {
      title: entry.title,
      url: browse_entry_url(entry, page),
      image: entry.file.nil? ? nil : entry.file.url,
      image_alt: nil
    }
  end

  ##
  # @param page [Page]
  def browse_entry_items(browse_entries, page = nil)
    browse_entries.map do |entry|
      browse_entry_item(entry, page)
    end
  end

  ##
  # @param page [Page]
  def browse_entry_items_grouped(browse_entries, page = nil)
    grouped_items, type1, type2, type3 = [], [], [], []

    more_links = [browse_people_path(theme: collection.key), browse_topics_path(theme: collection.key), browse_periods_path(theme: collection.key)]
    more_link_texts = [t('global.navigation.more.agents'), t('global.navigation.more.topics'), t('global.navigation.more.periods')]

    browse_entries.each do |entry|
      case entry.subject_type
      when 'person'
        type1 << browse_entry_item(entry, page)
      when 'topic'
        type2 << browse_entry_item(entry, page)
      when 'period'
        type3 << browse_entry_item(entry, page)
      end
    end

    no_of_item_types = 0
    [type1, type2, type3].each_with_index do |type, index|
      next unless type.count.positive?
      grouped_items << {
        more_link: more_links[index],
        more_text: more_link_texts[index],
        items: type
      }
      no_of_item_types += 1
    end

    return {
      grouped_items: grouped_items,
      is_single_type: no_of_item_types == 1
    }
  end
end
