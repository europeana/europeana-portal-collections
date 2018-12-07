# frozen_string_literal: true

RSpec.describe 'I18nData initializer' do
  describe '#normal_to_region_code' do
    subject { I18nData.send(:normal_to_region_code, normal) }

    context 'when param is "NO"' do
      let(:normal) { 'NO' }
      it { is_expected.to eq('NN') }
    end
  end
end
