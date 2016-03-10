RSpec.describe 'pages/show.html.mustache', :page_with_top_nav do
  before(:each) do
    assign(:page, page)
  end

  let(:page) { pages(:about) }

  it 'should have meta description' do
    render
    expect(rendered).to have_selector("meta[name=\"description\"][content=\"An introduction. Everything you need to know.\"]", visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(rendered).to have_selector("meta[name=\"HandheldFriendly\"]", visible: false)
  end
end
