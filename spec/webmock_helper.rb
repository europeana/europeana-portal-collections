require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) do
    ENV['EUROPEANA_API_KEY'] = 'test'
  end

  config.include EuropeanaAPIHelpers, type: :controller
end
