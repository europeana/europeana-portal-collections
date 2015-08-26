RSpec.describe Link do
  it { is_expected.to validate_presence_of(:url) }

#  it 'should allow HTTP URLs for :link' do
#  it { is_expected.to allow_value('http://example.com', 'https://www.example.com/sub/path.html').for(:url) }
#  it { is_expected.not_to allow_value('ftp://example.com', 'www.example.com/sub/path.html').for(:url) }

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(PaperTrail::Model::InstanceMethods)  }
  end
end
