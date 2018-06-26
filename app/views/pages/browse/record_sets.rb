# frozen_string_literal: true

module Pages
  module Browse
    class RecordSets < Pages::Show
      def js_var_page_name
        'portal/browse'
      end

      def bodyclass
        'channels-browse'
      end

      def content
        {
          anchor_title: page.sets.present?,
          browse_lists: page.sets&.map { |set| content_browse_list(set) }
        }
      end

      private

      def content_browse_list(set)
        {
          head: {
            title: set.title
          },
          foot: {
            link: {
              text: "More records like #{set.title}",
              url: search_path(q: set.title)
            }
          },
          items: set.europeana_ids&.map { |id| content_browse_list_item(id) }
        }
      end

      def content_browse_list_item(id)
        presenter = Document::SearchResultPresenter.new(documents[id], controller)

        {
          img_url: presenter.thumbnail_url,
          url: document_path(id: id[1..-1], format: 'html'),
          has_text: true,
          texts: [presenter.title, presenter.field_value(:year)]
        }
      end
    end
  end
end
