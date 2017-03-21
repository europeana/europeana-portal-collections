# frozen_string_literal: true
RSpec.describe Pro::Base do
  it { is_expected.to be_a(JsonApiClient::Resource) }

  describe '.site' do
    it 'appends /json/ to Pro.site' do
      expect(described_class.site).to eq(%(#{Pro.site}/json/))
    end
  end

  describe '#to_param' do
    before do
      module Pro
        class TestSubclass < Pro::Base; end
      end
    end
    let(:subclass) { Pro::TestSubclass }
    subject { subclass.new }

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
end
