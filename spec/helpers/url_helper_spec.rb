RSpec.describe UrlHelper do
  it { is_expected.to include(Blacklight::UrlHelperBehavior) }

  describe '#exhibitions_path' do
    subject { helper.exhibitions_path }
    it { is_expected.to eq('/en/exhibitions') }
  end

  describe '#exhibitions_foyer_path' do
    subject { helper.exhibitions_foyer_path }
    it { is_expected.to eq('/en/exhibitions/foyer') }
  end
end
