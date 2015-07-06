# Capybara integration
require 'capybara/rspec'
require 'capybara/rails'

Capybara.asset_host = 'http://develop.styleguide.eanadev.org'

if ENV['CAPYBARA_DRIVER'] == 'selenium'
  require 'selenium-webdriver'
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: (ENV['CAPYBARA_BROWSER'] || :firefox).to_sym)
  end
  Capybara.default_driver = :selenium
  Capybara.javascript_driver = :selenium
else
  require 'capybara/poltergeist'
  Capybara.configure do |config|
    config.default_driver = :poltergeist
    config.javascript_driver = :poltergeist
    config.current_driver = :poltergeist
    config.run_server = true
    config.default_wait_time = 10
  end

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app,
      phantomjs_options: [
        '--debug=no',
        '--load-images=no',
        '--ignore-ssl-errors=true',
        '--local-to-remote-url-access=yes',
        '--ssl-protocol=TLSv1',
        '--web-security=false',
         '--local-to-remote-url-access=true'
      ],
    extensions: ['http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'])
  end
    
  Capybara.javascript_driver = :poltergeist
  Capybara.default_selector  = :css

  RSpec.configure do |config|
    # Include Capybara for integration testing.
    config.include Capybara::DSL
  end
end
