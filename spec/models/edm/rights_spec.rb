RSpec.describe EDM::Rights do
  describe '.normalise' do
    subject { described_class.normalise(rights) }

    context 'when rights are a recognised URI' do
      let(:rights) { 'http://creativecommons.org/licenses/by-sa/3.0/de/' }
      it { is_expected.to be_a(described_class) }
      it 'should be normalised' do
        expect(subject.id).to eq(:cc_by_sa)
      end
    end

    context 'when rights are not recognised' do
      let(:rights) { 'http://www.example.com/rights' }
      it 'should raise an error' do
        expect { subject }.to raise_error(described_class.const_get('UnknownRights'))
      end
    end
  end
end
