RSpec.describe Facet::RangePresenter, presenter: :facet do
  let(:field_name) { 'RANGE_FIELD' }
  let(:field_options) { { range: true } }
  let(:item_type) { :number }

  it_behaves_like 'a facet presenter'

  describe '#hits_max' do
    let(:items) { facet_items(6) }
    subject { presenter.hits_max }
    it 'returns the maximum number of hits' do
      expect(subject).to eq(600)
    end
  end

  describe '#filter_item' do
    it 'should not attempt to translate range values'
  end
end
