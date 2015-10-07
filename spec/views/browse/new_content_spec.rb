RSpec.describe 'browse/new_content.html.mustache' do
  before(:each) do
    RSpec.configure do |config|
      config.mock_with :rspec do |mocks|
        mocks.verify_partial_doubles = false
      end
    end

#    assign(:page, 'about')
#    allow(view).to receive(:search_action_path).and_return('/search')
#    allow(view).to receive(:search_action_url).and_return('/search')
    Stache::ViewContext.current = view
  end

  let(:providers) do
    [
      { text: 'A Provider' },
      { text: 'Another Provider' },
      { text: 'A Different Provider' }
    ]
  end

  it 'should have page title' do
    page_title = 'New content'
    render
    expect(rendered).to have_selector('title', visible: false, text: page_title)
  end

  it 'should have meta description' do
    meta_content = 'New content'
    render
    expect(rendered).to have_selector("meta[name=\"description\"][content=\"#{meta_content}\"]", visible: false)
  end

  it 'should display a list of data providers' do
    assign(:providers, providers)
    render
    providers.each do |provider|
      expect(rendered).to have_selector('ul li a', text: provider[:text])
    end
  end
end
