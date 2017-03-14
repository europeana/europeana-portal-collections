# frozen_string_literal: true
RSpec.describe Pro::Person do
  it { is_expected.to be_a(Pro::Base) }

  describe '.table_name' do
    subject { described_class.table_name }
    it { is_expected.to eq('persons') }
  end
end
