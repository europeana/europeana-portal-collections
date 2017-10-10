# frozen_string_literal: true

RSpec.describe 'portal/show.html.mustache', :common_view_components, :blacklight_config, :stable_version_view do
  let(:blacklight_document_source) do
    # @todo Move to factory / fixture
    id = '/abc/123'
    {
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
  end
  let(:blacklight_document) { Europeana::Blacklight::Document.new(blacklight_document_source.with_indifferent_access) }
  let(:params) { { id: 'abc/123' } }

  before(:each) do
    allow(view).to receive(:current_search_session).and_return nil
    allow(view).to receive(:search_session).and_return({})
    allow(view).to receive(:search_action_path).and_return('/search')
    allow(view).to receive(:oembed_html).and_return({})
    allow(controller).to receive(:url_conversions).and_return({})
    allow(controller).to receive(:oembed_html).and_return({})

    assign(:params, params)
    assign(:document, blacklight_document)
    assign(:similar, [])
  end

  it 'should have meta description' do
    render
    expect(rendered).to have_selector('meta[name="description"]', visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(rendered).to have_selector('meta[name="HandheldFriendly"]', visible: false)
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

  context 'with colourpalette in API response' do
    let(:blacklight_document_source) { JSON.parse(api_responses(:record_with_colourpalette, id: '/abc/123'))['object'] }
    it 'shows colour links' do
      render
      expect(rendered).to have_selector('.colour-data')
      blacklight_document.fetch('aggregations.webResources.edmComponentColor').each do |colour|
        expect(rendered).to have_selector('.colour-data .colour-datum', text: colour)
      end
    end
  end

  context 'with q param' do
    let(:params) { { id: 'abc/123', q: 'paris' } }
    it 'should not have alternate links with q param' do
      render
      expect(rendered).not_to have_selector('link[rel="alternate"][hreflang="x-default"][href*="q=paris"]', visible: false)
    end
  end

  context 'when record has an entity agent' do
    let(:identifier) { '1234' }
    let(:api_response) { api_responses(:record_with_entity_agent, id: '/abc/123', identifier: identifier, proxy_field: 'dcCreator') }
    let(:blacklight_document_source) { JSON.parse(api_response)['object'] }

    it 'should have person link pointing to entity page' do
      render
      expect(rendered).to have_selector(%(a[href^="/en/explore/people/#{identifier}-"]))
    end
  end

  context 'when record has an entity concept' do
    let(:identifier) { '1234' }
    let(:api_response) { api_responses(:record_with_entity_concept, id: '/abc/123', identifier: identifier, proxy_field: 'dcFormat') }
    let(:blacklight_document_source) { JSON.parse(api_response)['object'] }

    it 'should have topic link pointing to entity page' do
      render
      expect(rendered).to have_selector(%(a[href^="/en/explore/topics/#{identifier}-"]))
    end
  end

  context 'without q param' do
    let(:params) { { id: 'abc/123' } }
    it 'should have a title "display_title | creator_title - Europeana Collections"' do
      render
      expect(rendered).to have_title(/(.*) | (.*) - #{t('site.name', default: 'Europeana Collections')}/)
    end
  end
end
