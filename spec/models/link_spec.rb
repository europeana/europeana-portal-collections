RSpec.describe Link do
  it { is_expected.to belong_to(:linkable) }
  it { is_expected.to validate_presence_of(:url) }

  it 'should validate :url as URL'

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(PaperTrail::Model::InstanceMethods) }
  end

  describe '#url_in_domain?' do
    context 'when URL is "http://www.europeana.eu/"' do
      let(:url) { 'http://www.europeana.eu/' }

      context 'domain is europeana.eu' do
        subject { described_class.new(url: url).url_in_domain?('europeana.eu') }
        it { is_expected.to be true }
      end

      context 'domain is europeana.com' do
        subject { described_class.new(url: url).url_in_domain?('europeana.com') }
        it { is_expected.to be false }
      end
    end
  end
end
