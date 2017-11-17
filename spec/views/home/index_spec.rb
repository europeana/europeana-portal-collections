RSpec.describe 'home/index.html.mustache', :common_view_components, :stable_version_view do
  include CollectionsHelper
  include RecordCountsHelper

  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.index.title_field = 'title_display'
    end
  end

  let(:landing_page) { pages(:home) }

  let(:collection) { collections(:all) }

  before(:each) do
    allow(controller).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:has_search_parameters?).and_return(false)
    assign(:landing_page, landing_page)
    assign(:collection, collection)
  end

  it 'should have meta description' do
    meta_content = collection_strapline(collection)
    meta_content = meta_content.strip! || meta_content
    render
    expect(rendered).to have_selector("meta[name=\"description\"][content=\"#{meta_content}\"]", visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(rendered).to have_selector("meta[name=\"HandheldFriendly\"]", visible: false)
  end

  it 'should have a title "Europeana Collections"' do
    render
    expect(rendered).to have_title(t('site.name', default: 'Europeana Collections'))
  end
end
