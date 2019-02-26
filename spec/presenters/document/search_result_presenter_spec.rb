# frozen_string_literal: true

RSpec.describe Document::SearchResultPresenter do
  let(:controller) { ActionView::TestCase::TestController.new }
  let(:bl_response) { Europeana::Blacklight::Response.new(api_response, {}) }
  let(:document) { bl_response.documents.first }
  let(:basic_api_response) { JSON.parse(api_responses(:search)) }
  let(:api_response) { basic_api_response }

  describe '#hit_selector' do
    subject { described_class.new(document, controller, api_response).hit_selector }

    context 'without API response' do
      let(:api_response) { nil }
      it { is_expected.to be_nil }
    end

    context 'without hit in API response' do
      it { is_expected.to be_nil }
    end

    context 'with hit in API response' do
      let(:api_response) do
        basic_api_response.tap do |response|
          response[:hits] = [
            {
              scope: response['items'].first['id'],
              selectors: [{ exact: 'query', prefix: 'before ', suffix: ' after' }]
            }
          ]
        end
      end

      it 'gets first selector' do
        expect(subject).to eq(api_response[:hits].first['selectors'].first)
      end
    end
  end
end
