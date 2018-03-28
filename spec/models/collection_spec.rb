# frozen_string_literal: true

RSpec.describe Collection do
  it { is_expected.to have_and_belong_to_many(:browse_entries) }
  it { is_expected.to have_one(:landing_page).dependent(:destroy) }
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
      expect { subject }.to have_enqueued_job(Cache::RecordCountsJob)
    end
  end

  describe '.settings_default_search_layout_enum' do
    subject { described_class.settings_default_search_layout_enum }
    it { is_expected.to eq(%w(list grid)) }
  end

  describe '#has_landing_page?' do
    context 'when there is NO landing page' do
      let(:collection) { collections(:internal) }
      subject { collection.has_landing_page? }
      it { is_expected.to be false }
    end

    context 'when there is a landing page' do
      let(:collection) { collections(:music) }
      subject { collection.has_landing_page? }
      it { is_expected.to be true }
    end
  end

  describe '#accepts_ugc?' do
    subject { described_class.new(key: key).accepts_ugc? }

    context 'when key is "world-war-I"' do
      let(:key) { 'world-war-I' }
      it { is_expected.to be true }
    end

    context 'when key is not "world-war-I"' do
      let(:key) { 'world-war-II' }
      it { is_expected.to be false }
    end
  end
end
