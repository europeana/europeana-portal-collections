# frozen_string_literal: true

# Methods for presenters needing to work with LangMap data from Europeana JSON APIs
#
# Expects the presenter class to implement a method +#document+ returning the
# +Hash+ of document metadata.
#
# @see Europeana::API::Record::LangMap
module LangMapDisplayingPresenter
  extend ActiveSupport::Concern

  delegate :localise_lang_map, to: Europeana::API::Record::LangMap

  # Renders a metadata field from API JSON responses with lang maps
  def field_value(fields)
    [fields].flatten.each do |field|
      value = [localise_lang_map(document[field])].flatten.map(&:to_s).join('; ')
      return value unless value.blank?
    end

    nil
  end

  alias_method :fv, :field_value
end
