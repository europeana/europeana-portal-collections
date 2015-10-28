RSpec.describe Collection do
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_uniqueness_of(:key) }
  it { is_expected.to validate_presence_of(:api_params) }

  describe '#to_param' do
    context 'when key eq "literature"' do
      let(:collection) { FactoryGirl.create(:collection, key: 'literature') }
      subject { collection.to_param }
      it { is_expected.to eq(collection.key) }
    end
  end
end
