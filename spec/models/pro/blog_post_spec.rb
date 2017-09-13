# frozen_string_literal: true
RSpec.describe Pro::BlogPost, :disable_verify_partial_doubles do
  it { is_expected.to be_a(Pro::Base) }

  let(:included_data) { double(JsonApiClient::IncludedData) }
  let(:last_result_set) { double(JsonApiClient::ResultSet) }

  before do
    if subject.is_a?(described_class)
      allow(last_result_set).to receive(:included) { included_data }
      allow(subject).to receive(:last_result_set) { last_result_set }
      allow(included_data).to receive(:has_link?) { false }
    end
  end

  describe '.table_name' do
    subject { described_class.table_name }
    it { is_expected.to eq('blogposts') }
  end

  context 'with persons' do
    before do
      allow(subject).to receive(:persons) { [double(Pro::Person)] }
      allow(included_data).to receive(:has_link?).with(:persons) { true }
    end
    it { is_expected.to have_authors }
  end

  context 'without persons or network' do
    it { is_expected.not_to have_authors }
  end
end
