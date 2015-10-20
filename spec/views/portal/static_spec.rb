require 'support/shared_examples/page_with_top_nav'

RSpec.describe 'portal/static.html.mustache' do
  before(:each) do
    assign(:page, page)
  end

  let(:page) { FactoryGirl.create(:page, body: '<p>Some info.</p> <p>More info.</p>') }

  it_should_behave_like 'page with top nav'

  it 'should have meta description' do
    render
    expect(rendered).to have_selector("meta[name=\"description\"][content=\"Some info. More info.\"]", visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(rendered).to have_selector("meta[name=\"HandheldFriendly\"]", visible: false)
  end
end
