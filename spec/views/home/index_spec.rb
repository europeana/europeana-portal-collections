RSpec.describe 'home/index.html.mustache' do
  let(:europeana_item_count) { 1234 }

  before(:each) do
    assign(:europeana_item_count, europeana_item_count)
    assign(:landing_page, landing_page)
    assign(:channel, channel)
  end

  let(:landing_page) { Page::Landing.find_by_slug('') }
  let(:channel) { Channel.find_by_key('home') }

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
