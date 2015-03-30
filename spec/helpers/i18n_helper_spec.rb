require 'rails_helper'

RSpec.describe I18nHelper, type: :helper do
  describe '#i18n' do
    subject { helper.i18n }
    it { is_expected.to be_instance_of(I18nHelper::Translator) }

    it "passes scope's String instance vars to translator" do
      assign(:name, 'smith')
      expect(subject.instance_variable_get(:@scope)[:name]).to eq('smith')
    end

    it "passes scope's Integer instance vars to translator" do
      assign(:age, 30)
      expect(subject.instance_variable_get(:@scope)[:age]).to eq(30)
    end

    it "does not pass scope's non-String/Integer instance vars to translator" do
      assign(:aliases, ['jones', 'bond'])
      assign(:siblings, {brothers: 2, sisters: 1})
      expect(subject.instance_variable_get(:@scope)).not_to have_key(:aliases)
      expect(subject.instance_variable_get(:@scope)).not_to have_key(:siblings)
    end

    it "does not pass scope's _ prefixed instance vars to translator" do
      assign(:_internal, 'use only')
      expect(subject.instance_variable_get(:@scope)).not_to have_key(:_internal)
    end
  end
end
