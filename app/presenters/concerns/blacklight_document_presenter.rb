# frozen_string_literal: true

module BlacklightDocumentPresenter
  extend ActiveSupport::Concern

  included do
    delegate :render_field_value, to: :blacklight_document_presenter
  end

  def blacklight_document_presenter
    @blacklight_document_presenter ||= Europeana::Blacklight::DocumentPresenter.new(document, controller)
  end

  ##
  # Override to prevent HTML escaping, handled by {Mustache}
  #
  # @see Blacklight::DocumentPresenter#render_values
  def render_values(values, field_config = nil)
    options = {}
    options = field_config.separator_options if field_config && field_config.separator_options

    values.to_sentence(options)
  end

  def field_value(fields, **options)
    unescape = options[:unescape]
    method = options[:context] == :index ? :render_index_field_value : :render_document_show_field_value

    [fields].flatten.each do |field|
      value = blacklight_document_presenter.send(method, field, options.except(:context, :unescape))
      value = CGI.unescapeHTML(value.to_str) if unescape
      return value unless value.blank?
    end

    nil
  end
end
