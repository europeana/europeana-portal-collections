RSpec.describe FacetsHelper do
  it { is_expected.to include(Blacklight::FacetsHelperBehavior) }

  describe '#facet_in_params?' do
    let(:collection_id) { 'art' }
    
    subject { helper.facet_in_params?(field, collection_id) }
    
    before(:each) do
      allow(helper).to receive(:params).and_return(params)
      allow(helper).to receive(:within_collection?).and_return(within_collection)
      allow(helper).to receive(:facet_value_for_facet_item).and_return(collection_id)
      helper.class.send(:include, Blacklight::Configurable)
    end

    context 'when field is "Collection"' do
      let(:field) { 'Collection' }

      context 'and viewing queried collection' do
        let(:params) { { id: collection_id } }
        let(:within_collection) { true }
        it { is_expected.to eq(true) }
      end

      context 'and viewing another collection' do
        let(:params) { { id: 'music' } }
        let(:within_collection) { true }
        it { is_expected.to eq(false) }
      end

      context 'and not viewing a collection' do
        let(:params) { { } }
        let(:within_collection) { false }
        it { is_expected.to eq(false) }
      end
    end

    context 'when field is not "Collection"' do
      let(:field) { 'YEAR' }

      context 'and viewing queried collection' do
        let(:params) { { id: collection_id } }
        let(:within_collection) { true }
        it { is_expected.to eq(false) }
      end

      context 'and viewing another collection' do
        let(:params) { { id: 'music' } }
        let(:within_collection) { true }
        it { is_expected.to eq(false) }
      end

      context 'and not viewing a collection' do
        let(:params) { { } }
        let(:within_collection) { false }
        it { is_expected.to eq(false) }
      end
    end
  end

  describe '#create_facet_field_response_for_query_facet_field' do
    it 'does stuff...'
  end
end
