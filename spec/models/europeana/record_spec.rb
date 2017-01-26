# frozen_string_literal: true
RSpec.describe Europeana::Record do
  it { is_expected.to have_many(:gallery_images).inverse_of(:europeana_record).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:europeana_id) }
  it { is_expected.to validate_uniqueness_of(:europeana_id) }
  it { is_expected.to allow_values('/abc/123', '/123/abc').for(:europeana_id) }
  it { is_expected.not_to allow_values('abc/123', 'record/123/abc', 'http://www.europeana.eu/').for(:europeana_id) }

  context 'when created' do
    it 'should enqueue a job to retrieve record metadata' do
      expect {
        described_class.create(europeana_id: '/job/enqueue')
      }.to have_enqueued_job(HarvestEuropeanaRecordJob)
    end
  end

  context 'when updated' do
    it 'should not enqueue a job to retrieve record metadata' do
      record = described_class.create(europeana_id: '/job/enqueue')
      expect {
        record.update_attributes(europeana_id: '/no/job')
      }.not_to have_enqueued_job(HarvestEuropeanaRecordJob)
    end
  end

  describe '#url' do
    it 'should construct portal URL from Europeana ID' do
      record = described_class.new(europeana_id: '/abc/123')
      expect(record.url).to eq('http://www.europeana.eu/portal/record/abc/123.html')
    end
  end

  describe '.europeana_id_from_url' do
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
          expect(described_class.europeana_id_from_url(url)).to eq('/abc/123')
        end
      end
    end
  end
end
