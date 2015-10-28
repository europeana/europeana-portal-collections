require 'support/shared_examples/page_with_top_nav'

RSpec.describe 'collections/show.html.mustache' do
  include ActionView::Helpers::TextHelper

  before(:each) do
    assign(:collection, collection)
    assign(:landing_page, landing_page)
  end

  let(:collection) { Collection.find_by_key('music') }
  let(:landing_page) { Page::Landing.find_by_slug('collections/music') }

  it_should_behave_like 'page with top nav'

  it 'should have meta description' do
    meta_content = truncate(ActionView::Base.full_sanitizer.sanitize(landing_page.body), length: 350, separator: ' ')
    render
    expect(rendered).to have_selector("meta[name=\"description\"][content=\"#{meta_content}\"]", visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(rendered).to have_selector("meta[name=\"HandheldFriendly\"]", visible: false)
  end
end
