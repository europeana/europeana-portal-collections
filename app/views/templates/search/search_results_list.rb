module Templates
  module Search
    class SearchResultsList < Stache::Mustache::View
      def pagetitle
        params['q']
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
