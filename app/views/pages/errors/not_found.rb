module Pages
  module Errors
    class NotFound < Portal::Static
      def content
        {
          intro: @page.title,
          text: @page.body
        }.reverse_merge(super)
      end
    end
  end
end
