# frozen_string_literal: true

RSpec.describe EDM::Entity do
  describe '.build_from_params' do
    subject { described_class.build_from_params(type: plural_human_type) }

    context 'when plural human type is "people"' do
      let(:plural_human_type) { 'people' }
      it { is_expected.to be_instance_of(EDM::Entity::Agent) }
    end

    context 'when plural human type is "periods"' do
      let(:plural_human_type) { 'periods' }
      it { is_expected.to be_instance_of(EDM::Entity::Timespan) }
    end

    context 'when plural human type is "places"' do
      let(:plural_human_type) { 'places' }
      it { is_expected.to be_instance_of(EDM::Entity::Place) }
    end

    context 'when plural human type is "topics"' do
      let(:plural_human_type) { 'topics' }
      it { is_expected.to be_instance_of(EDM::Entity::Concept) }
    end
  end
end
