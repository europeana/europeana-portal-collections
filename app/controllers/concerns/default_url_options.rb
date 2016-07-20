# frozen_string_literal: true

module DefaultUrlOptions
  def default_url_options(options = {})
    defaults = request_in_cms? ? {} : { locale: I18n.locale }
    defaults.merge!(options)
    defaults[:host] = ENV['HTTP_HOST'] if ENV['HTTP_HOST']
    defaults
  end

  def request_in_cms?
    self.class.to_s.deconstantize == 'RailsAdmin'
  end
end
