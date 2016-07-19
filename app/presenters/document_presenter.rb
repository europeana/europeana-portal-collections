##
# Base class for Blacklight document presenters
class DocumentPresenter < Europeana::Blacklight::DocumentPresenter
  delegate :t, to: I18n

  attr_reader :document, :controller

  ##
  # Override to prevent HTML escaping, handled by {Mustache}
  #
  # @see Blacklight::DocumentPresenter#render_values
  def render_values(values, field_config = nil)
    options = {}
    options = field_config.separator_options if field_config && field_config.separator_options

    values.to_sentence(options)
  end

  protected

  def routes
    Rails.application.routes.url_helpers
  end
end
