# frozen_string_literal: true

RSpec.describe EntitiesHelper do
  describe '#entities_api_type' do
    subject { helper.entities_api_type(human_type) }

    context 'when human type is "people"' do
      let(:human_type) { 'people' }
      it { is_expected.to eq('agent') }
    end

    context 'when human type is "periods"' do
      let(:human_type) { 'periods' }
      it { is_expected.to eq('timespan') }
    end

    context 'when human type is "places"' do
      let(:human_type) { 'places' }
      it { is_expected.to eq('place') }
    end

    context 'when human type is "topics"' do
      let(:human_type) { 'topics' }
      it { is_expected.to eq('concept') }
    end
  end

  describe '#entities_human_type' do
    subject { helper.entities_human_type(api_type) }

    context 'when API type is "agent"' do
      let(:api_type) { 'agent' }
      it { is_expected.to eq('people') }
    end

    context 'when API type is "timespan"' do
      let(:api_type) { 'timespan' }
      it { is_expected.to eq('periods') }
    end

    context 'when API type is "place"' do
      let(:api_type) { 'place' }
      it { is_expected.to eq('places') }
    end

    context 'when API type is "concept"' do
      let(:api_type) { 'concept' }
      it { is_expected.to eq('topics') }
    end
  end

  describe '#entity_url_slug' do
    subject { helper.entity_url_slug(entity) }

    context 'when entity has no English prefLabel' do
      let(:entity) { { prefLabel: { fr: 'Paris' } } }
      it { is_expected.to be_nil }
    end

    context 'when entity has an English prefLabel' do
      let(:entity) { { prefLabel: { en: 'David Hume' } } }

      it 'should URLify it' do
        expect(subject).to eq('david-hume')
      end
    end
  end
end
