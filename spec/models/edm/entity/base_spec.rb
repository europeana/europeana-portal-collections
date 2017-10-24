# frozen_string_literal: true

require 'helpers/i18n_helper_examples'

RSpec.describe EDM::Entity::Base do
  it_behaves_like 'i18n_helper'

  describe '.subclass_for_human_type' do
    subject { described_class.subclass_for_human_type(human_type) }

    context 'when human type is "person"' do
      let(:human_type) { 'person' }
      it { is_expected.to eq(EDM::Entity::Agent) }
    end

    context 'when human type is "period"' do
      let(:human_type) { 'period' }
      it { is_expected.to eq(EDM::Entity::Timespan) }
    end

    context 'when human type is "place"' do
      let(:human_type) { 'place' }
      it { is_expected.to eq(EDM::Entity::Place) }
    end

    context 'when human type is "topic"' do
      let(:human_type) { 'topic' }
      it { is_expected.to eq(EDM::Entity::Concept) }
    end
  end
end
