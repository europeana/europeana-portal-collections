require 'rails_helper'

RSpec.describe MustacheHelper::Translator, type: :model do
  subject { described_class.new(scope) }
  let(:scope) { { count: 10 } }

  let(:locale) { :en }
  let(:translations) do
    {
      name: 'Name',
      siblings: {
        brother: 'Brother',
        sister: 'Sister'
      },
      size: '%{count} members'
    }
  end

  before do
    I18n.backend.store_translations(I18n.locale, translations)
  end

  it 'acts like a Hash' do
    expect { subject['key'] }.not_to raise_error
    expect { subject.key?('key') }.not_to raise_error
    expect { subject.fetch('key') }.not_to raise_error
  end

  describe '#to_hash' do
    it 'returns self' do
      translator = subject
      expect(translator.to_hash).to eq(translator)
    end
  end

  describe '#[]' do
    it 'looks up key in I18n' do
      expect(subject['name']).to eq(translations[:name])
    end

    it 'handles nested keys' do
      expect(subject['siblings.brother']).to eq(translations[:siblings][:brother])
    end

    it 'handles parent keys' do
      expect(subject['siblings']).to be_a(described_class)
    end

    it 'interpolates placeholders from scope' do
      expect(subject['size']).to eq('10 members')
    end
  end
end
