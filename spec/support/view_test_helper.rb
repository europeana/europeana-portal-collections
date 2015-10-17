module ViewTestHelper
  RSpec.configure do |config|
    config.before(:each, type: :view) do
      RSpec.configure do |config|
        config.mock_with :rspec do |mocks|
          mocks.verify_partial_doubles = false
        end
      end

      allow(view).to receive(:search_action_path).and_return('/search')
      allow(view).to receive(:search_action_url).and_return('/search')
      allow(view).to receive(:current_user).and_return(User.new(guest: true))

      Stache::ViewContext.current = view
    end
  end
end
