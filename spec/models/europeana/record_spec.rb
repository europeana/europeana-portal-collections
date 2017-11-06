# frozen_string_literal: true

RSpec.describe Europeana::Record do
  it 'includes Annotations' do
    expect(described_class).to include(Europeana::Record::Annotations)
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

  describe '.search_api_query_for_record_ids' do
    subject { described_class.search_api_query_for_record_ids(record_ids) }
    let(:record_ids) { %w(/abc/123 /def/456) }

    it 'constructs an API search query term' do
      expect(subject).to eq('europeana_id:("/abc/123" OR "/def/456")')
    end
  end

  describe '#portal_url' do
    it 'should construct portal URL from Europeana ID' do
      expect(described_class.new('/abc/123').portal_url).to eq('https://www.europeana.eu/portal/record/abc/123.html')
    end
  end
end
