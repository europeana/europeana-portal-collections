# frozen_string_literal: true

RSpec.shared_context 'Disable verify partial doubles', :disable_verify_partial_doubles do
  # Some classes do not implement methods until initiated, e.g.
  # `JsonApiClient::Resource`, interfering with partial doubles.
  # This context disables partial double method verification then re-enables it.

  before(:all) do
    RSpec.configure do |config|
      config.mock_with :rspec do |mocks|
        mocks.verify_partial_doubles = false
      end
    end
  end

  after(:all) do
    RSpec.configure do |config|
      config.mock_with :rspec do |mocks|
        mocks.verify_partial_doubles = true
      end
    end
  end
end
