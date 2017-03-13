# frozen_string_literal: true
RSpec.describe Pro::Base do
  it { is_expected.to be_a(JsonApiClient::Resource) }

  describe '.site' do
    it 'appends /json/ to Pro.site' do
      expect(described_class.site).to eq(%(#{Pro.site}/json/))
    end
  end
end
