# frozen_string_literal: true

RSpec.describe CatalogHelper do
  it { is_expected.to include(Blacklight::CatalogHelperBehavior) }

  describe '#document_counter_with_offset' do
    let(:response) { double('response') }

    context 'when response is grouped' do
      it 'returns nil' do
        (1..3).each do |start|
          (1..5).each do |idx|
            allow(response).to receive(:params).and_return(start: start)
            allow(helper).to receive(:render_grouped_response?) { true }
            assign(:response, response)
            expect(helper.document_counter_with_offset(idx)).to be_nil
          end
        end
      end
    end

    context 'when response is not grouped' do
      it 'adds start param from response to index arg' do
        (1..3).each do |start|
          (1..5).each do |idx|
            allow(response).to receive(:params).and_return(start: start)
            allow(helper).to receive(:render_grouped_response?) { false }
            assign(:response, response)
            expect(helper.document_counter_with_offset(idx)).to eq(idx + start)
          end
        end
      end
    end
  end
end
