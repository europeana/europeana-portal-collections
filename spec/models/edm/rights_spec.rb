# frozen_string_literal: true

RSpec.describe EDM::Rights do
  describe '.normalise' do
    subject { described_class.normalise(rights) }

    context 'when rights are a recognised URI' do
      let(:rights) { 'http://creativecommons.org/licenses/by-sa/3.0/de/' }

      it { is_expected.to be_a(described_class) }

      it 'should be normalised' do
        expect(subject.id).to eq(:cc_by_sa)
      end

      context 'with https schema' do
        let(:rights) { 'https://creativecommons.org/licenses/by-sa/3.0/de/' }
        it 'should be detected' do
          expect(subject).to be_a(described_class)
          expect(subject.id).to eq(:cc_by_sa)
        end
      end
    end

    context 'when rights are not recognised' do
      let(:rights) { 'http://www.example.com/rights' }
      it { is_expected.to be_nil }
    end
  end
end
