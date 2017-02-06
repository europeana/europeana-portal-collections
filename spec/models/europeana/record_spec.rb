# frozen_string_literal: true
RSpec.describe Europeana::Record do
  describe '.portal_url_from_id' do
    it 'should construct portal URL from Europeana ID' do
      expect(described_class.portal_url_from_id('/abc/123')).to eq('http://www.europeana.eu/portal/record/abc/123.html')
    end
  end

  describe '.id_from_portal_url' do
    %w(
      http://www.europeana.eu/portal/record/abc/123.html
      http://www.europeana.eu/portal/record/abc/123
      https://www.europeana.eu/portal/record/abc/123.html
      https://www.europeana.eu/portal/record/abc/123
      http://www.europeana.eu/portal/en/record/abc/123.html
      https://www.europeana.eu/portal/de/record/abc/123
    ).each do |url|
      context %(when URL is "#{url}") do
        it 'should extract ID from URL' do
          expect(described_class.id_from_portal_url(url)).to eq('/abc/123')
        end
      end
    end
  end
end
