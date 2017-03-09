# frozen_string_literal: true
RSpec.describe Pro do
  describe '.site' do
    it 'should default to "http://pro.europeana.eu"' do
      expect(described_class.site).to eq('http://pro.europeana.eu')
    end
  end
end
