RSpec.describe 'channels/show.html.mustache' do
  before(:each) do
    RSpec.configure do |config|
      config.mock_with :rspec do |mocks|
        mocks.verify_partial_doubles = false
      end
    end

    assign(:channel, Channel.find('music'))
    allow(view).to receive(:search_action_path).and_return('/search')
    allow(view).to receive(:search_action_url).and_return('/search')
    Stache::ViewContext.current = view
  end

  it 'should have meta description' do
    meta_content = ActionView::Base.full_sanitizer.sanitize(I18n.t('site.channels.music.description'))
    render
    expect(rendered).to have_selector("meta[name=\"description\"][content=\"#{meta_content}\"]", visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(rendered).to have_selector("meta[name=\"HandheldFriendly\"]", visible: false)
  end
end
