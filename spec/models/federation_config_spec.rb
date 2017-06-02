# frozen_string_literal: true

RSpec.describe FederationConfig do
  it { is_expected.to belong_to(:collection) }
  it { is_expected.to validate_presence_of(:provider) }
  it { is_expected.to validate_presence_of(:collection) }
  it { is_expected.to validate_inclusion_of(:provider).in_array(described_class.provider_enum) }
  it { is_expected.to delegate_method(:provider_enum).to(:class) }

  describe '#provider_enum' do
    it 'should be derived from all the Foederati Providers' do
      expect(subject.provider_enum).to eq(Foederati::Providers.registry.keys - ['europeana'])
    end
  end
end
