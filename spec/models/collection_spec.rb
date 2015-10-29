RSpec.describe Collection do
  fixtures :collections

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_uniqueness_of(:key) }
  it { is_expected.to validate_presence_of(:api_params) }

  describe '#to_param' do
    context 'when key eq "music"' do
      let(:collection) { collections(:music) }
      subject { collection.to_param }
      it { is_expected.to eq(collection.key) }
    end
  end
end
