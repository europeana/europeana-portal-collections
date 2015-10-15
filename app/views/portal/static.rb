module Portal
  class Static < ApplicationView
    def page_title
      @mustache[:page_title] ||= begin
        @page.title
      end
    end

    def head_meta
      @mustache[:head_meta] ||= begin
        [
          { meta_name: 'description', content: truncate(strip_tags(@page.body), length: 350, separator: ' ') }
        ] + super
      end
    end

    def content
      @mustache[:content] ||= begin
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
end
