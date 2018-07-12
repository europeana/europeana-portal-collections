# frozen_string_literal: true

RSpec.describe Europeana::Record::Set do
  let(:page) { pages(:newspapers_a_to_z_browse) }
  let(:europeana_ids) { %w(/123/abc /456/def) }
  let(:valid_portal_urls) { %w(https://www.europeana.eu/portal/record/123/abc.html https://www.europeana.eu/portal/record/456/def.html) }
  let(:invalid_portal_url) { 'http://www.example.com/' }
  subject { described_class.new(page: page, title: 'C', europeana_ids: europeana_ids) }

  it { is_expected.to have_one(:page_element) }
  it { is_expected.to have_one(:page).through(:page_element) }
  it { is_expected.to validate_presence_of(:europeana_ids) }
  it { is_expected.to validate_presence_of(:title) }

  describe 'Portal URLs <=> Europeana IDs' do
    describe '#portal_urls' do
      it 'is an array of portal URLs derived from Europeana IDs' do
        subject.europeana_ids = europeana_ids
        expect(subject.portal_urls).to be_a(Array)
        valid_portal_urls.each do |url|
          expect(subject.portal_urls).to include(url)
        end
      end
    end

    describe '#portal_urls_text' do
      it 'is an string of portal URLs derived from Europeana IDs' do
        subject.europeana_ids = europeana_ids
        expect(subject.portal_urls_text).to be_a(String)
        valid_portal_urls.each do |url|
          expect(subject.portal_urls_text).to include(url)
        end
      end
    end

    describe '#portal_urls=' do
      it 'sets Europeana IDs from array of portal URLs' do
        subject.portal_urls = valid_portal_urls
        expect(subject.europeana_ids).to eq(europeana_ids)
      end
    end

    describe '#portal_urls_text=' do
      it 'sets Europeana IDs from array of portal URLs' do
        subject.portal_urls_text = valid_portal_urls.join("\n\n")
        expect(subject.europeana_ids).to eq(europeana_ids)
      end
    end
  end

  describe 'association touching' do
    describe 'after creation' do
      it 'touches page (through page_element)' do
        expect { subject.save! }.to change { page.reload.updated_at }
      end
    end

    describe 'after update' do
      it 'touches page (through page_element)' do
        subject.save!
        subject.europeana_ids.push('/789/ghi')
        expect { subject.save! }.to change { page.reload.updated_at }
      end
    end
  end

  describe '#query_term' do
    context 'with settings_query_term present' do
      it 'returns it' do
        subject.settings_query_term = 'QT'
        expect(subject.query_term).to eq(subject.settings_query_term)
      end
    end

    context 'without settings_query_term present' do
      it 'returns title' do
        subject.settings_query_term = nil
        expect(subject.query_term).to eq(subject.title)
      end
    end
  end

  describe '#validate_portal_urls_format' do
    before do
      subject.portal_urls = valid_portal_urls + [invalid_portal_url]
    end

    it 'flags invalid URLs' do
      subject.validate
      expect(subject.errors[:portal_urls_text].any? { |error| error.include?(invalid_portal_url) }).to be true
    end

    it 'does not flag valid URLs' do
      subject.validate
      valid_portal_urls.each do |valid_portal_url|
        expect(subject.errors[:portal_urls_text].none? { |error| error.include?(valid_portal_url) }).to be true
      end
    end
  end
end
