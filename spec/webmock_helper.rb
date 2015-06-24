require 'webmock/rspec'
require 'support/europeana_api_helper'
require 'support/europeana_blog_helper'

RSpec.configure do |config|
  config.before(:each) do
    ENV['EUROPEANA_API_KEY'] = 'test'
    WebMock.disable_net_connect!(:allow_localhost => true) # for poltergeist
  end

  config.include EuropeanaAPIHelper, type: :controller
  config.include EuropeanaBlogHelper, type: :controller
end
