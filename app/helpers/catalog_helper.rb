# frozen_string_literal: true

##
# BL catalog helper
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def document_counter_with_offset(idx)
    return nil if render_grouped_response?
    idx + @response.params[:start].to_i
  end
end
