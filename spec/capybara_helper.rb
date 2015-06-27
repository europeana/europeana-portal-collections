# Capybara integration
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'selenium-webdriver'

if (true) # false for local non-headless testing

  Capybara.register_driver :poltergeist do |app|
    options = {
      js_errors: true,
      timeout: 120,
      debug: false,
      #phantomjs_options: ['--load-images=no', '--disk-cache=false'],
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

else
  
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: :firefox)
  end
  Capybara.default_driver = :selenium
  Capybara.javascript_driver = :selenium

end
