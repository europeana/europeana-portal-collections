module Pages
  module Errors
    class NotFound < Portal::Static
      def content
        @mustache[:content] ||= begin
          {
            intro: @page.title,
            text: @page.body
          }.reverse_merge(super)
        end
      end
    end
  end
end
