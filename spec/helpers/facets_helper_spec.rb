# frozen_string_literal: true

RSpec.describe FacetsHelper do
  describe '#facet_in_params?' do
    subject { helper.facet_in_params?(field, item) }

    let(:field) { 'IMAGE_ASPECTRATIO' }
    let(:item) { OpenStruct.new(value: 'portrait') }

    it 'is case-insensitive' do
      %w(Portrait portrait PORTRAIT).each do |value|
        allow(helper).to receive(:params) { { f: { field => [value] } } }
        expect(subject).to be true
      end
    end
  end
end
