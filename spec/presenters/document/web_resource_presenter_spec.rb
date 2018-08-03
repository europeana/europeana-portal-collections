# frozen_string_literal: true

RSpec.describe Document::WebResourcePresenter do
  let(:controller) { ActionView::TestCase::TestController.new }

  let(:bl_response) { Europeana::Blacklight::Response.new(api_response, {}) }
  let(:record_document) { bl_response.documents.first }
  let(:wr_document) { record_document.aggregations.first.webResources.first }

  let(:api_response) { JSON.parse(api_responses(:record, id: '123/abc')) }

  subject { described_class.new(wr_document, controller, record_document) }

  context 'record without edm:isShownBy' do
    context 'record without edm:hasView' do
      context 'for edm:object' do
        let(:api_response) { JSON.parse(api_responses(:record_with_edm_object, id: '123/abc')) }

        it { is_expected.to be_for_edm_object }
        it { is_expected.to be_displayable }
        it { is_expected.not_to be_playable }
        it { is_expected.not_to be_downloadable }
      end
    end
  end
end
