# frozen_string_literal: true

RSpec.describe EntityDisplayingView do
  let(:view_class) do
    Class.new do
      include EntityDisplayingView
      include I18nHelper
      delegate :t, to: :I18n
    end
  end

  let(:view_instance) { view_class.new }

  subject { view_instance }

  before do
    allow(view_instance).to receive(:mustache) { {} }
  end

  describe '#entity_thumbnail_source' do
    let(:entity) do
      JSON.parse(api_responses(:entities_fetch_agent, name: 'Entity Name', description: 'Entity Description')).
        with_indifferent_access
    end

    context 'with depiction' do
      before do
        subject.instance_variable_set(:@entity, entity)
      end

      it 'returns depiction source' do
        expect(subject.entity_thumbnail_source).to eq(entity[:depiction][:source])
      end
    end

    context 'without depiction' do
      before do
        subject.instance_variable_set(:@entity, entity.except(:depiction))
      end

      it 'is nil' do
        expect(subject.entity_thumbnail_source).to be_nil
      end
    end
  end

  describe '#entity_date' do
    context 'when date has unformattable value first' do
      let(:date) { ['not a date', '0046'] }
      it 'uses and formats known value' do
        expect(subject.send(:entity_date, date)).to eq('46 CE')
      end
    end

    context 'when date has no formattable value' do
      let(:date) { [' unknown 1 ', ' unknown 2 '] }
      it 'strips and returns first value' do
        expect(subject.send(:entity_date, date)).to eq('unknown 1')
      end
    end
  end

  describe '#entity_description_title' do
    subject { view_instance.entity_description_title }

    before do
      allow(view_instance).to receive(:api_type) { entity_type }
    end

    context 'when entity type is agent' do
      let(:entity_type) { 'agent' }
      it { is_expected.to eq('Biography') }
    end

    context 'when entity type is concept' do
      let(:entity_type) { 'concept' }
      it { is_expected.to eq('Description') }
    end
  end
end
