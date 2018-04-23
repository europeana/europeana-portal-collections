# frozen_string_literal: true

require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) do
    WebMock.disable_net_connect!(allow_localhost: true) # for poltergeist
  end
end
