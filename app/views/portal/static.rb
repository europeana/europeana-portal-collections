module Portal
  class Static < ApplicationView
    def page_title
      @page.title
    end

    def content
      {
        title: @page.title,
        text: @page.body
      }.merge(helpers.content)
    end
  end
end
