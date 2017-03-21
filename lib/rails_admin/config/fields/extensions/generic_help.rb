# frozen_string_literal: true
module RailsAdmin
  module Config
    module Fields
      module Extensions
        ##
        # This just duplicates the `#generic_help` method from
        # `RailsAdmin::Config::Fields::Types::String` to be mixed in to
        # `RailsAdmin::Config::Fields::Types::Text`.
        #
        # @todo suggest to RailsAdmin devs that this method be included in
        #   `RailsAdmin::Config::Fields::Types::Text`
        module GenericHelp
          def generic_help
            text = (required? ? I18n.translate('admin.form.required') : I18n.translate('admin.form.optional')) + '. '
            if valid_length.present? && valid_length[:is].present?
              text += "#{I18n.translate('admin.form.char_length_of').capitalize} #{valid_length[:is]}."
            else
              max_length = [length, valid_length[:maximum] || nil].compact.min
              min_length = [0, valid_length[:minimum] || nil].compact.max
              if max_length
                text +=
                  if min_length == 0
                    "#{I18n.translate('admin.form.char_length_up_to').capitalize} #{max_length}."
                  else
                    "#{I18n.translate('admin.form.char_length_of').capitalize} #{min_length}-#{max_length}."
                  end
              end
            end
            text
          end
        end
      end
    end
  end
end
