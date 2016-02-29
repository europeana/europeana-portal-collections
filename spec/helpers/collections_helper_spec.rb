RSpec.describe CollectionsHelper do
  describe '#available_collections' do
    subject { helper.available_collections }
    it 'should eq collection keys' do
      expect(subject).to eq(Collection.all.map(&:key))
    end
  end

  describe '#within_collection?' do
    context 'when search was in a collection' do
      let(:params) { { controller: 'collections', id: 'art' } }
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

  describe '#current_collection' do
    before(:each) do
      allow(helper).to receive(:params).and_return(params)
    end

    subject { helper.current_collection }

    context 'when within a collection' do
      let(:params) { { controller: 'collections', id: 'music' } }
      it 'returns the collection' do
        expect(subject).to be_a(Collection)
        expect(subject.key).to eq('music')
      end
    end

    context 'when not within a collection' do
      let(:params) { { controller: 'welcome' } }
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#displayable_collections' do
    subject { helper.displayable_collections }

    it 'should exclude unpublished collections' do
      expect(subject).not_to include(collections(:draft))
    end
    it 'should exclude published collections with unpublished landing pages' do
      expect(subject).not_to include(collections(:art))
    end
    it 'should include published collections with published landing pages' do
      expect(subject).to include(collections(:music))
    end
  end
end
