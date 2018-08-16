# frozen_string_literal: true

RSpec.describe 'portal/show.html.mustache', :common_view_components, :blacklight_config, :stable_version_view do
  include ProJsonApiConsumingView

  let(:record_id) { '/123/abc' }
  let(:record_param) { record_id[1..-1] }

  let(:blacklight_document_source) do
    # TODO: Move to factory / fixture
    id = record_id
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
  let(:params) { { controller: 'portal', action: 'show', id: record_param } }

  before(:each) do
    allow(view).to receive(:current_search_session).and_return nil
    allow(view).to receive(:search_session).and_return({})
    allow(view).to receive(:search_action_path).and_return('/search')
    allow(view).to receive(:oembed_html).and_return({})
    allow(controller).to receive(:url_conversions).and_return({})
    allow(controller).to receive(:oembed_html).and_return({})
    allow(controller).to receive(:media_headers).and_return({})

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

  describe '@new_design' do
    context 'when true' do
      before do
        assign(:new_design, true)
      end

      it 'renders templates/Search/Channels-object' do
        render
        expect(rendered).to have_selector('div.channel-object-overview')
        expect(rendered).not_to have_selector('div.object-overview')
      end

      it 'sets pageName JS var to "portal/show-new"' do
        render
        expect(rendered).to include('var pageName = "portal/show-new";')
      end

      describe 'enabledPromos JS var' do
        let(:enabled_promos) do
          JSON.parse(rendered.match(/var enabledPromos = (.*);/)[1])
        end

        it 'includes gallery' do
          render
          expect(enabled_promos).to be_any do |promo|
            promo['id'] == 'gallery' &&
              promo['url'] == document_galleries_url(record_param, format: 'json')
          end
        end

        it 'includes Pro JSON API blog post' do
          render
          expect(enabled_promos).to be_any do |promo|
            promo['id'] == 'blog' &&
              promo['url'] == pro_json_api_posts_for_record_url(record_id)
          end
        end

        context 'when record has dcterms:isPartOf' do
          let(:blacklight_document_source) do
            {
              about: record_id,
              title: ["Record #{record_id}"],
              proxies: [
                {
                  'europeanaProxy': false,
                  'dctermsIsPartOf': {
                    'def': parent_uri
                  }
                }
              ],
              aggregations: [{}],
              'type': 'IMAGE'
            }
          end

          context 'which is a Europeana item URI' do
            let(:parent_uri) { 'http://data.europeana.eu/item/123/def' }

            it 'includes parent promo' do
              render
              expect(enabled_promos).to be_any do |promo|
                promo['id'] == 'generic' &&
                  promo['url'] == document_parent_url(record_id[1..-1], format: 'json')
              end
            end
          end

          context 'which is not a Europeana item URI' do
            let(:parent_uri) { "http://data.example.org/item/123/def" }

            it 'includes parent promo' do
              render
              expect(enabled_promos).not_to be_any do |promo|
                promo['id'] == 'generic' &&
                  promo['url'] == document_parent_url(record_id[1..-1], format: 'json')
              end
            end
          end
        end
      end

      it 'sets body class to "channels-item"' do
        render
        expect(rendered).to have_selector('body.channels-item')
      end
    end

    context 'when false' do
      before do
        assign(:new_design, false)
      end

      it 'renders templates/Search/Search-object' do
        render
        expect(rendered).to have_selector('div.object-overview')
        expect(rendered).not_to have_selector('div.channel-object-overview')
      end

      it 'sets pageName JS var to "portal/show"' do
        render
        expect(rendered).to include('var pageName = "portal/show";')
      end

      it 'does not set body class to "channels-item"' do
        render
        expect(rendered).not_to have_selector('body.channels-item')
      end
    end
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
