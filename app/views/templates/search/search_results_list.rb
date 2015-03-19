module Templates
  module Search
    class SearchResultsList < Stache::Mustache::View
      def pagetitle
        params['q']
      end

      def searchresults
        @document_list
      end
    end
  end
end
