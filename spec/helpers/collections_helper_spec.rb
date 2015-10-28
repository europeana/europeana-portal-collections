RSpec.describe CollectionsHelper do
  describe '#available_collections' do
    before do
      3.times do
        FactoryGirl.create(:collection)
      end
    end
    subject { helper.available_collections }
    it 'should eq collection keys' do
      expect(subject).to eq(Collection.all.map(&:key))
    end
  end
  
  describe '#within_collection?' do
    context 'when search was in a collection' do
      let(:params) { { 'controller' => 'collections', 'id' => 'art' } }
      subject { helper.within_collection?(params) }
      it { is_expected.to eq(true) }
    end

    context 'when search was not in a collection' do
      it 'should eq false' do
        [
          { 'controller' => 'other' },
          { 'controller' => 'collections' },
          { 'controller' => 'other', 'id' => 'art' }
        ].each do |params|
          expect(helper.within_collection?(params)).to eq(false)
        end
      end
    end
  end
end
