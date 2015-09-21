require 'webmock/rspec'
require 'support/europeana_api_helper'

RSpec.configure do |config|
  config.before(:each) do
    WebMock.disable_net_connect!(allow_localhost: true) # for poltergeist
  end

  config.include EuropeanaAPIHelper
end
