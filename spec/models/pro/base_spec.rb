# frozen_string_literal: true

RSpec.describe Pro::Base, :disable_verify_partial_doubles do
  it { is_expected.to be_a(JsonApiClient::Resource) }

  describe '.site' do
    it 'appends /json/ to Pro.site' do
      expect(described_class.site).to eq(%(#{Pro.site}/json/))
    end
  end

  describe '#to_param' do
    context 'when resource has slug attr' do
      before do
        subject.attributes['slug'] = 'pellet'
      end

      it 'returns slug' do
        expect(subject.to_param).to eq('pellet')
      end
    end

    context 'when resource has no slug attr' do
      it 'is nil' do
        expect(subject.to_param).to be_nil
      end
    end
  end

  context 'without taxonomy' do
    it { is_expected.not_to have_taxonomy }
    it { is_expected.not_to have_taxonomy(:tags) }
  end

  context 'with taxonomy' do
    before do
      allow(subject).to receive(:taxonomy) { { a: [] } }
    end
    it { is_expected.to have_taxonomy }
    it { is_expected.not_to have_taxonomy(:tags) }

    context 'with tags' do
      before do
        allow(subject).to receive(:taxonomy) { { tags: ['a'] } }
      end
      it { is_expected.to have_taxonomy(:tags) }
    end
  end
end
