# frozen_string_literal: true
module Document
  module Field
    module Labelling
      extend ActiveSupport::Concern

      def pref_label(document, field_name)
        val = document.fetch(field_name, [])
        pref = nil
        if val.size > 0
          if val.is_a?(Array)
            val[0]
          else
            pref = val[0][I18n.locale.to_sym]
            if pref.size > 0
              pref[0]
            else
              val[0][:en]
            end
          end
        end
      end
    end
  end
end
