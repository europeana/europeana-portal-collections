class MustacheDocumentPresenter < Europeana::Blacklight::DocumentPresenter
  # Overriden to disable HTML escaping which is handled by {Mustache}
  def render_field_value(value = nil, field_config = nil)
    safe_values = Array(value).collect { |x| x.respond_to?(:force_encoding) ? x.force_encoding("UTF-8") : x }

    if field_config and field_config.itemprop
      safe_values = safe_values.map { |x| content_tag :span, x, :itemprop => field_config.itemprop }
    end

    safe_values.join((field_config.separator if field_config) || field_value_separator)
  end
end
