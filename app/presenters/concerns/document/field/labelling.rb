# frozen_string_literal: true
module Document
  module Field
    module Labelling
      extend ActiveSupport::Concern

      def pref_label(document, field_name)
        val = document.fetch(field_name, [])
        return if val.empty?

        if val.is_a?(Array)
          val[0]
        else
          pref = val[0][I18n.locale.to_sym]
          pref.empty? ? val[0][:en] : pref[0]
        end
      end
    end
  end
end
