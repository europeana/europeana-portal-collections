RSpec.describe I18nHelper do
  describe '#enabled_ui_locales' do
    subject { helper.enabled_ui_locales }

    it { is_expected.to include(:en) }
    it { is_expected.to include(:nl) }
  end

  describe '#locale_language_keys' do
    subject { helper.locale_language_keys }

    it 'should return language translation keys' do
      expect(subject).to have_key(:en)
      expect(subject[:en]).to eq('english')
    end

    it 'should have indifferent access' do
      expect(subject).to have_key(:nl)
      expect(subject[:nl]).to eq(subject['nl'])
    end
  end

  describe '#enabled_ui_language_keys' do
    subject { helper.enabled_ui_language_keys }

    it 'should return only enabled keys' do
      expect(subject.keys.map(&:to_sym)).to eq(helper.enabled_ui_locales)
    end
  end
end
