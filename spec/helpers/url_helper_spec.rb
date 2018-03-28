# frozen_string_literal: true

RSpec.describe UrlHelper do
  it { is_expected.to include(Blacklight::UrlHelperBehavior) }

  describe '#exhibitions_path' do
    context 'when the locale is the default' do
      subject { helper.exhibitions_path }
      it { is_expected.to eq('/en/exhibitions') }
    end

    context 'when a separate locale is provided' do
      subject { helper.exhibitions_path 'fr' }
      it { is_expected.to eq('/fr/exhibitions') }
    end
  end

  describe '#exhibitions_foyer_path' do
    context "when the locale isn't provided" do
      subject { helper.exhibitions_foyer_path }
      it { is_expected.to eq('/en/exhibitions/foyer') }
    end
    context "when there's a separate locale provided" do
      subject { helper.exhibitions_foyer_path 'fr' }
      it { is_expected.to eq('/fr/exhibitions/foyer') }
    end
  end
end
