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

        it { is_expected.to be_for_edm_is_shown_at }
        it { is_expected.not_to be_displayable }
        it { is_expected.not_to be_playable }
        it { is_expected.not_to be_downloadable }

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
end
