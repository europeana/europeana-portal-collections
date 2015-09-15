RSpec.describe 'portal/static.html.mustache' do
  before(:each) do
    RSpec.configure do |config|
      config.mock_with :rspec do |mocks|
        mocks.verify_partial_doubles = false
      end
    end

    assign(:page, 'about')
    allow(view).to receive(:search_action_path).and_return('/search')
    allow(view).to receive(:search_action_url).and_return('/search')
    Stache::ViewContext.current = view
  end

  it 'should have meta description' do
    para = Nokogiri::HTML(I18n.t('site.pages.about.text')).xpath('//p').first.text
    meta_content = ActionView::Base.full_sanitizer.sanitize(para)
    render
    expect(rendered).to have_selector("meta[name=\"description\"][content=\"#{meta_content}\"]", visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(rendered).to have_selector("meta[name=\"HandheldFriendly\"]", visible: false)
  end
end
