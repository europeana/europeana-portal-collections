# frozen_string_literal: true

RSpec.describe Document::WebResourcePresenter do
  let(:controller) { ActionView::TestCase::TestController.new }

  let(:bl_response) { Europeana::Blacklight::Response.new(api_response, {}) }
  let(:record_document) { bl_response.documents.first }
  let(:wr_document) { record_document.aggregations.first.webResources.detect { |wr| wr[:about] == wr_url } }
  let(:record_id) { '/123/abc' }
  let(:wr_url) { "http://provider.example.com#{record_id}" }
  let(:europeana_edm_is_shown_at) { 'http://www.europeana.eu/api/api2demo/redirect?shownAt=' + CGI.escape(wr_url) }

  let(:base_api_response) do
    {
      success: true,
      object: {
        about: record_id,
        title: ["Record #{record_id}"],
        proxies: [{}],
        aggregations: [
          { webResources: [
            { about: wr_url }
          ] }
        ],
        'type': 'IMAGE'
      }
    }
  end

  let(:api_response) { base_api_response }

  subject { described_class.new(wr_document, controller, record_document) }

  context 'record without edm:isShownBy' do
    context 'record without edm:hasView' do
      context 'for edm:object' do
        let(:api_response) do
          base_api_response.tap do |response|
            response[:object][:aggregations].first[:edmObject] = wr_url
          end
        end

        it { is_expected.to be_for_edm_object }
        it { is_expected.to be_displayable }
        it { is_expected.not_to be_playable }
        it { is_expected.not_to be_downloadable }
      end

      context 'for edm:isShownAt' do
        let(:api_response) do
          base_api_response.tap do |response|
            response[:object][:aggregations].first[:edmIsShownAt] = europeana_edm_is_shown_at
          end
        end

        context 'when identical to edm:isShownBy' do
          before do
            api_response[:object][:aggregations].first[:edmIsShownBy] = wr_url
          end
          it { is_expected.to be_for_edm_is_shown_at }
          it { is_expected.to be_displayable }
          it { is_expected.to be_downloadable }
        end

        context 'when matching an oEmbed pattern' do
          before do
            allow(subject).to receive(:controller_oembed_html) { { wr_url => { html: '<iframe/>' } } }
          end

          it { is_expected.to be_for_edm_is_shown_at }
          it { is_expected.to be_displayable }
          it { is_expected.to be_playable }
          it { is_expected.not_to be_downloadable }
        end
      end

      context 'when matching an oEmbed pattern' do
        before do
          allow(subject).to receive(:controller_oembed_html) { { wr_url => { html: '<iframe/>' } } }
        end

        it { is_expected.to be_displayable }
        it { is_expected.to be_playable }
        it { is_expected.not_to be_downloadable }
      end
    end
  end

  context 'record with iiif webresource' do
    let(:iif_service) { 'http://iiif.example.org/iiif' }
    context 'when it is a single page' do
      let(:api_response) do
        base_api_response.tap do |response|
          response[:object][:services] = [
            {
              'about': iif_service,
              'dctermsConformsTo': [
                'http://iiif.io/api/image'
              ]
            }
          ]
          response[:object][:aggregations].first.tap do |agg|
            agg[:edmIsShownBy] = wr_url
            agg[:webResources].first.tap do |wr|
              wr[:svcsHasService] = [iif_service]
              wr[:ebucoreHasMimeType] = 'image/jpeg'
            end
          end
        end
      end

      it { is_expected.to be_iiif }
      it { is_expected.to be_displayable }
      it { is_expected.to be_playable }
      it { is_expected.to be_downloadable }

      it 'should have the manifest' do
        expect(subject.iiif_manifest).to eq('http://iiif.example.org/iiif/info.json')
      end
    end

    context 'when it has a manifest' do
      let(:api_response) do
        base_api_response.tap do |response|
          response[:object][:services] = [
            {
              'about': iif_service,
              'dctermsConformsTo': [
                'http://iiif.io/api/image'
              ]
            }
          ]
          response[:object][:aggregations].first.tap do |agg|
            agg[:edmIsShownBy] = wr_url
            agg[:webResources].first.tap do |wr|
              wr[:svcsHasService] = [iif_service]
              wr[:dctermsIsReferencedBy] = 'https://www.example.org/iiif/manifest.json'
              wr[:ebucoreHasMimeType] = 'image/jpeg'
            end
          end
        end
      end

      it { is_expected.to be_iiif }
      it { is_expected.to be_displayable }
      it { is_expected.to be_playable }
      it { is_expected.to be_downloadable }

      it 'should have the manifest' do
        expect(subject.iiif_manifest).to eq('https://www.example.org/iiif/manifest.json')
      end
    end

    context 'when it refers to a page in a europeana IIIF manifest' do
      let(:api_response) do
        base_api_response.tap do |response|
          response[:object][:services] = [
            {
              'about': iif_service,
              'dctermsConformsTo': [
                'http://iiif.io/api/image'
              ]
            }
          ]
          response[:object][:aggregations].first.tap do |agg|
            agg[:webResources].first.tap do |wr|
              wr[:svcsHasService] = [iif_service]
              wr[:dctermsIsReferencedBy] = 'https://iiif.europeana.eu/presentation/123/abc/manifest'
              wr[:ebucoreHasMimeType] = 'image/jpeg'
            end
          end
        end
      end

      it { is_expected.to be_iiif }
      it { is_expected.to be_playable }
      it { is_expected.to_not be_displayable }
      it { is_expected.to_not be_downloadable }

      it 'should have the manifest' do
        expect(subject.iiif_manifest).to eq('https://iiif.europeana.eu/presentation/123/abc/manifest')
      end
    end
  end
end
