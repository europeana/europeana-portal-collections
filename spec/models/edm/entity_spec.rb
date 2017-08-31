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

  describe '#entity_thumbnail_source' do
    let(:id) { '123' }
    let(:type) { 'person' }
    let(:entity) do
      JSON.parse(api_responses(:entities_fetch_agent, name: 'Entity Name', description: 'Entity Description')).
        with_indifferent_access
    end

    subject { described_class.build_from_params(type: type, id: id, m: entity) }

    context 'with depiction' do
      it 'returns depiction source'
      # it 'returns depiction source' do
      #   expect(subject.entity_thumbnail_source).to eq(entity[:depiction][:source])
      # end
    end

    context 'without depiction' do
      before do
        subject.instance_variable_set(:@entity, entity.except(:depiction))
      end

      it 'is nil'
      # it 'is nil' do
      #   expect(subject.entity_thumbnail_source).to be_nil
      # end
    end
  end

  describe '#entity_date' do
    context 'when date has unformattable value first' do
      let(:date) { ['not a date', '0046'] }
      it 'uses and formats known value'
      # it 'uses and formats known value' do
      #   expect(subject.send(:entity_date, date)).to eq('46 CE')
      # end
    end

    context 'when date has no formattable value' do
      let(:date) { [' unknown 1 ', ' unknown 2 '] }
      it 'strips and returns first value'
      # it 'strips and returns first value' do
      #   expect(subject.send(:entity_date, date)).to eq('unknown 1')
      # end
    end
  end
end
