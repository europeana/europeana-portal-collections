# frozen_string_literal: true

RSpec.describe EDM::Entity::Concept do
  describe '.human_type' do
    subject { described_class.human_type }
    it { is_expected.to eq('topic') }
  end

  describe '#search_query' do
    subject { described_class.new.search_query }
    it { is_expected.to match %r{/concept/} }
  end
end
