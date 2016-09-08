module Europeana
  module UrlConversions
    class TelQueryAppender < Base
      def map_one_uri(uri)
        uri + '?query=' + CGI.escape(@controller.params[:q])
      end

      def uri_mappable?(uri)
        !uri.match(%r{\Ahttp://www.theeuropeanlibrary.org/tel4/newspapers/issue/fullscreen/}).nil?
      end

      def is_runnable?
        @controller.params.key?(:q)
      end
    end
  end
end
