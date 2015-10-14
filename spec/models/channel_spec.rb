RSpec.describe Channel do
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_uniqueness_of(:key) }
  it { is_expected.to validate_presence_of(:api_params) }

  describe '#to_param' do
    context 'when key eq "literature"' do
      let(:channel) { FactoryGirl.create(:channel, key: 'literature') }
      subject { channel.to_param }
      it { is_expected.to eq(channel.key) }
    end
  end
end
