require 'rails_helper'

RSpec.describe Templates::Search::SearchHome, type: false do
  it { is_expected.to be_a(ApplicationView) }

  describe '#test' do
    it 'says hello' do
      expect(described_class.new.test).to eq('hello')
    end
  end
end
