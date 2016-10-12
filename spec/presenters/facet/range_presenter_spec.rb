# @todo spec this better when it's actually in use
RSpec.describe Facet::RangePresenter, presenter: :facet do
  let(:field_name) { 'RANGE_FIELD' }
  let(:field_options) { { range: true } }
  let(:item_type) { :number }

  describe '#hits_max' do
    let(:items) { facet_items(6) }
    subject { presenter.hits_max }
    it 'returns the maximum number of hits' do
      expect(subject).to eq(600)
    end
  end

  describe '#range_max' do
    let(:items) { facet_items(6) }
    subject { presenter.range_max }
    it 'returns the top of the range' do
      expect(subject).to eq(6)
    end
  end

  describe '#range_min' do
    let(:items) { facet_items(6) }
    subject { presenter.range_min }
    it 'returns the bottom of the range' do
      expect(subject).to eq(1)
    end
  end

end
