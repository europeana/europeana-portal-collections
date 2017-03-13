# frozen_string_literal: true
RSpec.describe Pro do
  describe '.site' do
    it %(should be "#{Rails.application.config.x.europeana[:pro_url]}") do
      expect(described_class.site).to eq(Rails.application.config.x.europeana[:pro_url])
    end
  end
end
