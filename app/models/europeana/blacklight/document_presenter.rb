module Europeana
  module Blacklight
    ##
    # Blacklight document presenter for Europeana documents
    class DocumentPresenter < ::Blacklight::DocumentPresenter
      include ActionView::Helpers::AssetTagHelper

      def render_document_show_field_value(field, options = {})
        value = super
        value = image_tag(value) if field.match(/(\A|\.)edmPreview\Z/)
        value
      end
    end
  end
end
