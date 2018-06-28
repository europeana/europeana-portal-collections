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

      def content_browse_list_foot_link_text
        @content_browse_list_foot_link_text ||= begin
          page.settings_link_text.present? ? page.settings_link_text : t('site.pages.browse.record_sets.link_text')
        end
      end

      def content_browse_list(set)
        {
          head: {
            title: set.title
          },
          foot: {
            link: {
              text: format(content_browse_list_foot_link_text, set_title: set.title),
              url: content_browse_list_foot_link_url(set)
            }
          },
          items: set.europeana_ids&.map { |id| content_browse_list_item(id) }
        }
      end

      def content_browse_list_foot_link_url(set)
        set_query = format(page.settings_set_query, set_query_term: CGI.escape(set.query_term))
        search_url_with_query([page.settings_base_query, set_query].compact.join('&'))
      end

      # TODO: favour lang aware title, and truncate, per +SearchResultPresenter#title+
      def content_browse_list_item(id)
        return {} if items[id].blank?

        img_url = thumbnail_url_for_edm_preview(items[id]['edmPreview']&.first)
        texts = [items[id]['title']&.first, items[id]['year']&.first].compact

        {
          img_url: img_url,
          url: document_path(id: id[1..-1], format: 'html'),
          has_text: texts.present?,
          texts: texts
        }
      end
    end
  end
end
