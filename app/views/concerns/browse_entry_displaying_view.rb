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
    grouped_items, type1, type2 = [], [], []

    more_links = [browse_people_path(theme: collection.key), browse_topics_path(theme: collection.key)]
    more_link_texts = [t('global.navigation.more.agents'), t('global.navigation.more.topics')]

    if browse_entries[0].subject_type != 'person'
      more_links.reverse!
      more_link_texts.reverse!
    end

    browse_entries.each do |entry|
      (entry.subject_type == browse_entries[0].subject_type ? type1 : type2) << browse_entry_item(entry, page)
    end

    if type1.count > 0
      grouped_items << {
                         more_link: more_links[0],
                         more_text: more_link_texts[0],
                         items: type1
                       }
    end

    if type2.count > 0
      grouped_items << {
                         more_link: more_links[1],
                         more_text: more_link_texts[1],
                         items: type2
                       }
    end

    return {
      grouped_items: grouped_items,
      is_single_type: type1.count == 0 || type2.count == 0
    }
  end
end
