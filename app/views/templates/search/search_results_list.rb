module Templates
  module Search
    class SearchResultsList < Stache::Mustache::View
      def pagetitle
        params['q']
      end

      def filters
        facets_from_request(facet_field_names).collect do |f|
          {
            simple: true,
            title: f.name,
            items: f.items.collect do |i|
              {
                url: search_action_path(add_facet_params_and_redirect(f.name, i)),
                text: i.value,
                num_results: i.hits
              }
            end
          }
        end
      end

      def header_text
        query_terms = params['q'].split(' ').collect do |query_term|
          content_tag(:strong, query_term)
        end
        "#{response.total} results for " + query_terms.join(' and ')
      end
      
      def searchresults
        @document_list.collect do |doc|
          {
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
    end
  end
end
