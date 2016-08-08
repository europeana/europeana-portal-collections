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

    type1 = []
    type2 = []

    browse_entries.each do |entry|
      (entry.subject_type == 'person' ? type1 : type2) << browse_entry_item(entry, page)
    end

    [
      {
        more_link: browse_people_path(theme: collection.key),
        more_text: t('global.navigation.more.agents'),
        items: type1
      },
      {
        more_link: browse_topics_path(theme: collection.key),
        more_text: t('global.navigation.more.topics'),
        items: type2
      }
    ]
  end
end
