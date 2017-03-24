# frozen_string_literal: true
RSpec.describe Pro::Location do
  it { is_expected.to be_a(Pro::Base) }

  describe '.table_name' do
    subject { described_class.table_name }
    it { is_expected.to eq('locations') }
  end
end
