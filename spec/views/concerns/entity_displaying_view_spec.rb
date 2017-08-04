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
