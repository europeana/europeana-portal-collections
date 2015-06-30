# Capybara integration
require 'capybara/rspec'
require 'capybara/rails'

if ENV['CAPYBARA_DRIVER'] == 'selenium'
  require 'selenium-webdriver'
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: (ENV['CAPYBARA_BROWSER'] || :firefox).to_sym)
  end
  Capybara.default_driver = :selenium
  Capybara.javascript_driver = :selenium
else
  require 'capybara/poltergeist'
  Capybara.register_driver :poltergeist do |app|
    options = {
      js_errors: true,
      timeout: 120,
      debug: false,
      inspector: true,
      ignore_ssl_errors: true
    }
    Capybara::Poltergeist::Driver.new(app, options)
  end

  Capybara.javascript_driver = :poltergeist
  Capybara.default_selector  = :css

  RSpec.configure do |config|
    # Include Capybara for integration testing.
    config.include Capybara::DSL
  end
end
