# frozen_string_literal: true

RSpec.describe 'pages/show.html.mustache', :common_view_components, :stable_version_view do
  before(:each) do
    assign(:page, page)
    assign(:params, page: page.slug)
  end

  let(:page) { pages(:about) }

  it 'should have meta description' do
    render
    expect(rendered).to have_selector('meta[name="description"][content="An introduction. Everything you need to know."]', visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(rendered).to have_selector('meta[name="HandheldFriendly"]', visible: false)
  end
end
