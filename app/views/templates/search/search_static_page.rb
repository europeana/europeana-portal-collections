module Templates
  module Search
    class SearchStaticPage < ApplicationView
      def content
        {
#          title: page_title(@page),
#          text: page_text(@page)
        }
      end

      def navigation
      end

      def version
      end
    end
  end
end
