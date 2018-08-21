# frozen_string_literal: true

# Capybara integration
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.configure do |config|
  config.default_max_wait_time = 10
  config.default_selector = :css
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
                                    phantomjs_options: [
                                      '--local-to-remote-url-access=true'
                                    ],
                                    js_errors: true,
                                    phantomjs_logger: File.new(File.join(Rails.root, 'log', 'phantomjs.log'), 'w'),
                                    debug: false)
end

Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  # Include Capybara for integration testing.
  config.include Capybara::DSL
end
