# frozen_string_literal: true

RSpec.describe EDM::Entity::Agent do
  describe '.human_type' do
    subject { described_class.human_type }
    it { is_expected.to eq('person') }
  end

  describe '#search_query' do
    subject { described_class.new.search_query(:items_by) }
    it { is_expected.to match %r{/agent/} }
  end
end
