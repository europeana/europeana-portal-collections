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
    context 'when date has integer value second' do
      let(:date) { ['c. AD 46', '0046'] }
      it 'uses and formats integer value' do
        expect(subject.send(:entity_date, date)).to eq('46 CE')
      end
    end
  end
end
