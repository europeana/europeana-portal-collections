require 'support/shared_examples/page_with_top_nav'

RSpec.describe 'portal/static.html.mustache' do
  fixtures :pages

  before(:each) do
    assign(:page, page)
  end

  let(:page) { pages(:about) }

  it_should_behave_like 'page with top nav'

  it 'should have meta description' do
    render
    expect(rendered).to have_selector("meta[name=\"description\"][content=\"An introduction. Everything you need to know.\"]", visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(rendered).to have_selector("meta[name=\"HandheldFriendly\"]", visible: false)
  end
end
