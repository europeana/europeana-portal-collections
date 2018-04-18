# frozen_string_literal: true

RSpec.describe Document::RecordPresenter do
  let(:controller) { ActionView::TestCase::TestController.new }
  let(:bl_response) { Europeana::Blacklight::Response.new(api_response, {}) }
  let(:document) { bl_response.documents.first }
  let(:basic_api_response) { JSON.parse(api_responses(:record, id: 'abc/123')) }
  let(:api_response) { basic_api_response }

  describe '#media_rights' do
    subject { described_class.new(document, controller).media_rights }

    context 'with proxy dc:rights starting "http://rightsstatements.org/page/"' do
      let(:dc_rights) { 'http://rightsstatements.org/page/NoC-OKLR/1.0/?relatedURL=http://gallica.bnf.fr/html/conditions-dutilisation-des-contenus-de-gallica' }
      let(:api_response) do
        basic_api_response.tap do |record|
          record['object']['proxies'].first['dcRights'] = {
            def: [dc_rights]
          }
        end
      end

      it 'is used' do
        expect(subject).to eq(dc_rights)
      end
    end

    context 'without proxy dc:rights starting "http://rightsstatements.org/page/"' do
      let(:dc_rights) { 'http://example.org/dc/rights' }
      let(:edm_rights) { 'http://example.org/edm/rights' }
      let(:api_response) do
        basic_api_response.tap do |record|
          record['object']['proxies'].first['dcRights'] = {
            def: [dc_rights]
          }
          record['object']['aggregations'].first['edmRights'] = {
            def: [edm_rights]
          }
        end
      end

      it 'uses aggregation edm:rights' do
        expect(subject).to eq(edm_rights)
      end
    end
  end
end
