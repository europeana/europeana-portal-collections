# frozen_string_literal: true

RSpec.describe EDM::Entity::Place do
  describe '.human_type' do
    subject { described_class.human_type }
    it { is_expected.to eq('place') }
  end
end
