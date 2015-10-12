require 'rails_helper'

RSpec.describe ApplicationView, type: :view do
  it { is_expected.to be_a(Europeana::Styleguide::View) }

  describe '#i18n' do
    subject { described_class.new.i18n }
    it { is_expected.to be_instance_of(Europeana::Styleguide::View::Translator) }

    it 'sets the context as the translator scope' do
      view = described_class.new
      expect(view.i18n.instance_variable_get(:@scope)).to eq(view.context)
    end
  end

  describe '#debug' do
    subject { described_class.new.debug }
    it { is_expected.to eq(false) }
  end
end
