class MustacheDocumentPresenter < Europeana::Blacklight::DocumentPresenter
  def render_field_value(value = nil, field_config = nil)
    safe_values = Array(value)

    if field_config && field_config.limit.is_a?(Integer)
      max_i = field_config.limit - 1
      safe_values = safe_values[0..max_i]
    end

    safe_values.collect! { |x| x.respond_to?(:force_encoding) ? x.force_encoding("UTF-8") : x }

    if field_config && field_config.itemprop
      safe_values = safe_values.map { |x| content_tag :span, x, :itemprop => field_config.itemprop }
    end

    # Do not use {safe_join} to escape HTML because that is done by {Mustache}
    safe_values.join((field_config.separator if field_config) || field_value_separator)
  end
end
