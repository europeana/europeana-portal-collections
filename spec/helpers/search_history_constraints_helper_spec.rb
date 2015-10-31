RSpec.describe SearchHistoryConstraintsHelper do
  it { is_expected.to include(Blacklight::SearchHistoryConstraintsHelperBehavior) }

  describe '#render_search_to_s' do
    context 'when search was in a collection' do
      let(:params) { { 'controller' => 'collections', 'id' => 'art' } }
      subject { helper.render_search_to_s(params) }
      it { is_expected.to include('Collection') }
      it { is_expected.to include('art') }
    end

    context 'when search was not in a collection' do
      it 'should not include collection search summary' do
        [
          { 'controller' => 'other' },
          { 'controller' => 'collections' },
          { 'controller' => 'other', 'id' => 'art' }
        ].each do |params|
          expect(helper.render_search_to_s(params)).not_to include('Collection')
        end
      end
    end
  end

  describe '#render_search_to_s_collection' do
    context 'when search was in a collection' do
      let(:params) { { 'controller' => 'collections', 'id' => 'art' } }
      subject { helper.render_search_to_s_collection(params) }
      it { is_expected.to include('Collection') }
      it { is_expected.to include('art') }
    end

    context 'when search was not in a collection' do
      it 'should not include collection search summary' do
        [
          { 'controller' => 'other' },
          { 'controller' => 'collections' },
          { 'controller' => 'other', 'id' => 'art' }
        ].each do |params|
          expect(helper.render_search_to_s_collection(params)).to eq('')
        end
      end
    end
  end
end
