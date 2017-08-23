# frozen_string_literal: true

RSpec.describe EntityDisplayingView do
  let(:view_class) do
    Class.new do
      include EntityDisplayingView
      include I18nHelper
      delegate :t, to: :I18n
    end
  end

  subject { view_class.new }

  before do
    allow(subject).to receive(:mustache) { {} }
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
end
