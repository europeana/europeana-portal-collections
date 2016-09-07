RSpec.describe Collection do
  it { is_expected.to have_and_belong_to_many(:browse_entries) }
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_uniqueness_of(:key) }
  it { is_expected.to validate_presence_of(:api_params) }
  it { is_expected.to delegate_method(:settings_default_search_layout_enum).to(:class) }

  describe '#to_param' do
    context 'when key eq "music"' do
      let(:collection) { collections(:music) }
      subject { collection.to_param }
      it { is_expected.to eq(collection.key) }
    end
  end

  describe '#publish' do
    subject { collections(:draft).publish }
    it 'should enqueue a record counts job' do
      expect { subject }.to change { Delayed::Job.where("handler LIKE '%Cache::RecordCountsJob%'").count }.by(1)
    end
  end

  describe '.settings_default_search_layout_enum' do
    subject { described_class.settings_default_search_layout_enum }
    it { is_expected.to eq(%w(list grid)) }
  end
end
