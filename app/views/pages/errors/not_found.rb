module Pages
  module Errors
    class NotFound < Portal::Static
      def content
        {
          intro: @page.title,
          text: @page.body
        }.merge(helpers.content)
      end
    end
  end
end
