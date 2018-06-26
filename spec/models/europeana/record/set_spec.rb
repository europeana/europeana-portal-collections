# frozen_string_literal: true

RSpec.describe Europeana::Record::Set do
  it { is_expected.to have_one(:page_element) }
  it { is_expected.to have_one(:page).through(:page_element) }
  it { is_expected.to validate_presence_of(:europeana_ids) }
  it { is_expected.to validate_presence_of(:title) }

  describe 'Portal URLs <=> Europeana IDs' do
    let(:europeana_ids) { %w(/123/abc /456/def) }
    let(:portal_urls) { %w(https://www.europeana.eu/portal/record/123/abc.html https://www.europeana.eu/portal/record/456/def.html) }

    describe '#portal_urls' do
      it 'is an array of portal URLs derived from Europeana IDs' do
        subject.europeana_ids = europeana_ids
        expect(subject.portal_urls).to be_a(Array)
        portal_urls.each do |url|
          expect(subject.portal_urls).to include(url)
        end
      end
    end

    describe '#portal_urls_text' do
      it 'is an string of portal URLs derived from Europeana IDs' do
        subject.europeana_ids = europeana_ids
        expect(subject.portal_urls_text).to be_a(String)
        portal_urls.each do |url|
          expect(subject.portal_urls_text).to include(url)
        end
      end
    end

    describe '#portal_urls=' do
      it 'sets Europeana IDs from array of portal URLs' do
        subject.portal_urls = portal_urls
        expect(subject.europeana_ids).to eq(europeana_ids)
      end
    end

    describe '#portal_urls_text=' do
      it 'sets Europeana IDs from array of portal URLs' do
        subject.portal_urls_text = portal_urls.join("\n\n")
        expect(subject.europeana_ids).to eq(europeana_ids)
      end
    end
  end
end
