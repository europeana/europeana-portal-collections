module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def render_index_field_value(*args)
    val = super
    # Mustache outputs empty strings, but not nil values; we don't want to
    # display empty fields.
    val == '' ? nil : val
  end

  def render_document_show_field_value(*args)
    val = super
    # Mustache outputs empty strings, but not nil values; we don't want to
    # display empty fields.
    val == '' ? nil : val
  end
end
