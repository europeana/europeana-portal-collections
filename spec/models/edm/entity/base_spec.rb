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

  describe '#schema_org_json_ld_url' do
    let(:api_url) { 'http://www.example.org/api' }
    let(:api_key) { 'SECRET_KEY' }

    before do
      allow(EDM::Entity).to receive(:api_url) { api_url }
      allow(EDM::Entity).to receive(:api_key) { api_key }
    end

    it 'is JSON-LD schema.org URL' do
      entity = described_class.new(id: 567)
      expected = "#{api_url}/entities/base/base/567.schema.jsonld?wskey=#{api_key}"
      expect(entity.schema_org_json_ld_url).to eq(expected)
    end
  end
end
