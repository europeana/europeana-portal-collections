RSpec.describe 'portal/show.html.mustache', :page_with_top_nav, :blacklight_config do
  let(:blacklight_document) do
    # @todo Move to factory / fixture
    id = '/abc/123'
    source = {
      about: id,
      title: [id],
      proxies: [
        {
          dcCreator: { def: ['Mister Smith'] },
          dcDescription: { en: ['About Mr Smith'] }
        }
      ],
      aggregations: [
        { edmIsShownBy: "http://provider.example.com#{id}" }
      ]
    }
    Europeana::Blacklight::Document.new(source)
  end

  before(:each) do
    allow(view).to receive(:current_search_session).and_return nil
    allow(view).to receive(:search_session).and_return({})
    allow(view).to receive(:search_action_path).and_return('/search')
    allow(view).to receive(:oembed_html).and_return({})

    assign(:params, { id: 'abc/123' })
    assign(:document, blacklight_document)
    assign(:similar, [])
  end

  it 'should have meta description' do
    render
    expect(rendered).to have_selector("meta[name=\"description\"]", visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(rendered).to have_selector("meta[name=\"HandheldFriendly\"]", visible: false)
  end

  context 'with @debug' do
    let(:msg) { 'Useful information for debugging' }

    it 'displays debug output' do
      assign(:debug, msg)
      render
      expect(rendered).to have_selector('pre.utility_debug')
      expect(rendered).to have_content(msg)
    end
  end

  context 'without @debug' do
    it 'hides debug output' do
      render
      expect(rendered).not_to have_selector('pre.utility_debug')
    end
  end
end
