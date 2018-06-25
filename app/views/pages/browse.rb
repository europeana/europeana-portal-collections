# frozen_string_literal: true

module Pages
  class Browse < Pages::Show
    def js_vars
      super.tap do |vars|
        page_name_var = vars.detect { |var| var[:name] == 'pageName' }
        page_name_var[:value] = 'portal/browse-page'
      end
    end
  end
end
