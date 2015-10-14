RSpec.describe 'channels/show.html.mustache' do
  include ActionView::Helpers::TextHelper

  before(:each) do
    assign(:channel, channel)
    assign(:landing_page, landing_page)
  end

  let(:channel) { FactoryGirl.create(:channel, :music) }
  let(:landing_page) { FactoryGirl.create(:landing_page, :music_channel) }

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
