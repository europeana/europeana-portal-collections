# frozen_string_literal: true

# Capybara integration
require 'capybara/rspec'
require 'capybara/rails'

Capybara.configure do |config|
  config.default_max_wait_time = 10
  config.default_selector = :css
end

Capybara.register_driver :firefox_headless do |app|
  options = ::Selenium::WebDriver::Firefox::Options.new
  options.args << '--headless'

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end

Capybara.javascript_driver = :firefox_headless

RSpec.configure do |config|
  # Include Capybara for integration testing.
  config.include Capybara::DSL
end
