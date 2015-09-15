RSpec.describe 'home/index.html.mustache' do
  let(:europeana_item_count) { 1234 }

  before(:each) do
    RSpec.configure do |config|
      config.mock_with :rspec do |mocks|
        mocks.verify_partial_doubles = false
      end
    end

    assign(:europeana_item_count, europeana_item_count)

    allow(view).to receive(:search_action_path).and_return('/search')
    allow(view).to receive(:search_action_url).and_return('/search')
    Stache::ViewContext.current = view
  end

  it 'should have meta description' do
    meta_content = I18n.t('site.home.strapline', total_item_count: europeana_item_count)
    render
    expect(rendered).to have_selector("meta[name=\"description\"][content=\"#{meta_content}\"]", visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(rendered).to have_selector("meta[name=\"HandheldFriendly\"]", visible: false)
  end
end
