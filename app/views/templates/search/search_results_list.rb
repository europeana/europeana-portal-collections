module Templates
  module Search
    class SearchResultsList < Stache::Mustache::View
      def pagetitle
        params['q']
      end

      def filters
        facets_from_request(facet_field_names).collect do |facet|
          {
            simple: true,
            title: facet.name,
            items: facet.items.collect do |item|
              {
                url: facet_item_url(facet.name, item),
                text: item.value,
                num_results: number_with_delimiter(item.hits),
                'is-checked': facet_in_params?(facet.name, item)
              }
            end
          }
        end
      end

      def header_text
        query_terms = params['q'].split(' ').collect do |query_term|
          content_tag(:strong, query_term)
        end
        number_with_delimiter(response.total) + ' results for ' + query_terms.join(' and ')
      end

      def searchresults
        @document_list.collect do |doc|
          {
            objectUrl: url_for_document(doc),
            title: doc.get(:title),
            text: {
              medium: truncate(doc.get(:dcDescription), length: 140, separator: ' ')
            },
            year: {
              long: doc.get(:year)
            },
            origin: {
              text: doc.get(:dataProvider),
              url: doc.get(:edmIsShownAt)
            },
            isImage: doc.get(:type) == 'IMAGE',
            isAudio: doc.get(:type) == 'SOUND',
            isText: doc.get(:type) == 'TEXT',
            isVideo: doc.get(:type) == 'VIDEO',
            img: {
              rectangle: {
                src: doc.get(:edmPreview),
                alt: ''
              }
            }
          }
        end
      end

      private

      def facet_item_url(facet, item)
        if facet_in_params?(facet, item)
          search_action_path(remove_facet_params(facet, item, params))
        else
           search_action_path(add_facet_params_and_redirect(facet, item))
        end
      end
    end
  end
end
