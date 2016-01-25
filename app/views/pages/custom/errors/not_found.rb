module Pages
  module Custom
    module Errors
      class NotFound < Pages::Show
        def content
          mustache[:content] ||= begin
            {
              intro: @page.title,
              text: @page.body
            }.reverse_merge(super)
          end
        end
      end
    end
  end
end
