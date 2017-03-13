# frozen_string_literal: true
RSpec.describe Pro::Network do
  it { is_expected.to be_a(Pro::Base) }

  describe '.table_name' do
    it 'should be "network"' do
      expect(described_class.table_name).to eq('network')
    end
  end
end
