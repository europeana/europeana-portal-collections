# frozen_string_literal: true
RSpec.describe Pro::Base do
  it { is_expected.to be_a(JsonApiClient::Resource) }

  describe '.site' do
    it 'defaults to "http://pro.europeana.eu/json/"' do
      expect(described_class.site).to eq('http://pro.europeana.eu/json/')
    end
  end
end
