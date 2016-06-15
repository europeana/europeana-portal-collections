RSpec.describe 'collections/show.html.mustache', :page_with_top_nav, :blacklight_config do
  include ActionView::Helpers::TextHelper

  before(:each) do
    assign(:collection, collection)
    assign(:landing_page, landing_page)
    allow(controller).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    render
  end

  let(:collection) { Collection.find_by_key('music') }
  let(:landing_page) { Page::Landing.find_by_slug('collections/music') }

  subject { rendered }

  it 'should have meta description' do
    meta_content = truncate(ActionView::Base.full_sanitizer.sanitize(landing_page.body), length: 350, separator: ' ')
    expect(subject).to have_selector("meta[name=\"description\"][content=\"#{meta_content}\"]", visible: false)
  end

  it 'should have meta HandheldFriendly' do
    expect(subject).to have_selector("meta[name=\"HandheldFriendly\"]", visible: false)
  end

  it 'should have a search field' do
    expect(subject).to have_field('q')
  end

  it 'should have a browse menu' do
    expect(subject).to have_selector('#browse-menu')
    expect(subject).to have_link('Images')
  end
end
