##
# For views needing to display `BrowseEntry` objects
module BrowseEntryDisplayingView
  extend ActiveSupport::Concern

  protected

  ##
  # @param page [Page]
  def browse_entry_items(browse_entries, page = nil)
    browse_entries.map do |entry|
      {
        title: entry.title,
        url: browse_entry_url(entry, page),
        image: entry.file.nil? ? nil : entry.file.url,
        image_alt: nil
      }
    end
  end
end
