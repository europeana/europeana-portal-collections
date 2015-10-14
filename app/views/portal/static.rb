module Portal
  class Static < ApplicationView
    def page_title
      @page.title
    end

    def head_meta
      [
        { meta_name: 'description', content: truncate(strip_tags(@page.body), length: 350, separator: ' ') }
      ] + super
    end

    def content
      {
        title: @page.title,
        text: @page.body,
        channel_entry: @page.browse_entries.blank? ? nil : {
          items: channel_entry_items(@page.browse_entries)
        },
      }.merge(helpers.content)
    end
  end
end
