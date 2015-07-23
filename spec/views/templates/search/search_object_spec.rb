RSpec.describe 'templates/Search/Search-object.html.mustache' do
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.index.title_field = 'title_display'
    end
  end

  let(:blacklight_document) do
    # @todo Move to factory
    id = '/abc/123'
    source = {
      'about' => id,
      'title' => [id],
      'proxies' => [
        { 'dcCreator' => { 'def' => ['Mister Smith'] } }
      ],
      'aggregations' => [
        { 'edmIsShownBy' => "http://provider.example.com#{id}" }
      ]
    }
    Europeana::Blacklight::Document.new(source)
  end

  before(:each) do
    RSpec.configure do |config|
      config.mock_with :rspec do |mocks|
        mocks.verify_partial_doubles = false
      end
    end
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:current_search_session).and_return nil
    allow(view).to receive(:search_session).and_return({})
    allow(view).to receive(:search_action_path).and_return('/search')
  end

  context 'with @debug' do
    let(:msg) { 'Useful information for debugging' }

    it 'displays debug output' do
      assign(:document, blacklight_document)
      assign(:similar, [])
      assign(:debug, msg)
      render
      expect(rendered).to have_selector('pre.utility_debug')
      expect(rendered).to have_content(msg)
    end
  end

  context 'without @debug' do
    it 'hides debug output' do
      assign(:document, blacklight_document)
      assign(:similar, [])
      render
      expect(rendered).not_to have_selector('pre.utility_debug')
    end
  end
end
