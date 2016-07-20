module DefaultUrlOptions
  def default_url_options(options = {})
    defaults = request_in_cms? ? {} : { locale: I18n.locale }
    defaults.merge!(options)
    if ENV['HTTP_HOST']
      defaults.merge!(host: ENV['HTTP_HOST'] )
    end
    defaults
  end

  def request_in_cms?
    self.class.to_s.deconstantize == 'RailsAdmin'
  end
end
