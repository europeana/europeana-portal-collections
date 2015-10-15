# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if Europeana::Portal::Application.config.relative_url_root.present?
  map '/' do
    run lambda { |env|
      [301, { 'Location' => Europeana::Portal::Application.config.relative_url_root }, []]
    }
  end

  map Europeana::Portal::Application.config.relative_url_root do
    run Rails.application
  end
else
  run Rails.application
end
