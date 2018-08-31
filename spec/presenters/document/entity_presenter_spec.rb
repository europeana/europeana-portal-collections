# frozen_string_literal: true

RSpec.describe Document::EntityPresenter do
  let(:controller) { ActionView::TestCase::TestController.new }
  let(:document) { Europeana::Blacklight::Document.new(api_response) }
  let(:api_response) { {} }

  subject { described_class.new(document, controller) }

  describe '#extra' do
    subject { described_class.new(document, controller).extra(extras) }

    context 'when extra is just a field' do
      let(:field) { 'latitude' }
      let(:extras) do
        [
          {
            field: field
          }
        ]
      end
      let(:api_response) do
        { field => 60.0 }
      end
      it 'includes it as a string' do
        expect(subject[field.to_sym]).to eq(api_response[field].to_s)
      end
    end

    context 'when extra has map_to' do
      let(:field) { 'dcType' }
      let(:extras) do
        [
          {
            field: field,
            map_to: 'something.else'
          }
        ]
      end
      let(:api_response) do
        { field => 'value' }
      end
      it 'includes it nested at the map_to key' do
        expect(subject[:something][:else]).to eq(api_response[field].to_s)
      end
    end

    context 'when extra has format_date' do
      let(:unformatted_date) { '2018-08-13T16:24:46.952+02:00' }
      let(:date_format) { '%Y-%m-%d' }
      let(:formatted_date) { '2018-08-13' }
      let(:field) { 'dctermsCreated' }
      let(:extras) do
        [
          {
            field: field,
            format_date: date_format
          }
        ]
      end
      let(:api_response) do
        { field => unformatted_date }
      end
      it 'includes it nested at the map_to key' do
        expect(subject[field.to_sym]).to eq(formatted_date)
      end
    end
  end
end
