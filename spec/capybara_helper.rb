# Capybara integration
require 'capybara/rspec'
require 'capybara/rails'

if ENV['CAPYBARA_DRIVER'] == 'selenium'
  require 'selenium-webdriver'

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: (ENV['CAPYBARA_BROWSER'] || :firefox).to_sym)
  end

  Capybara.javascript_driver = :selenium
else
  require 'capybara/poltergeist'

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app,
      phantomjs_options: [
        '--local-to-remote-url-access=true'
      ],
      js_errors: true
    )
  end

  Capybara.configure do |config|
    config.javascript_driver = :poltergeist
    config.default_wait_time = 10
    config.default_selector  = :css
  end

  RSpec.configure do |config|
    # Include Capybara for integration testing.
    config.include Capybara::DSL
  end
end
