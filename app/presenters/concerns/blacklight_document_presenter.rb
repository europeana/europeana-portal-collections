# frozen_string_literal: true

module BlacklightDocumentPresenter
  extend ActiveSupport::Concern

  included do
    delegate :render_field_value, to: :blacklight_document_presenter
  end

  def blacklight_document_presenter
    @blacklight_document_presenter ||= NoEscapePresenter.new(document, controller)
  end

  class NoEscapePresenter < Europeana::Blacklight::DocumentPresenter
    delegate :t, to: I18n

    ##
    # Override to prevent HTML escaping, handled by {Mustache}
    #
    # @see Blacklight::DocumentPresenter#render_values
    def render_values(values, _field_config = nil)
      values.join(t('global.punctuation.list-item-separator'))
    end
  end

  def field_value(fields, **options)
    method = options[:context] == :index ? :render_index_field_value : :render_document_show_field_value

    [fields].flatten.each do |field|
      value = blacklight_document_presenter.send(method, field, options.except(:context))
      return value unless value.blank?
    end

    nil
  end
end
