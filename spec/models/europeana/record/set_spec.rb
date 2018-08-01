# frozen_string_literal: true

RSpec.describe Europeana::Record::Set do
  let(:page) { pages(:newspapers_a_to_z_browse) }
  let(:europeana_ids) { %w(/123/abc /456/def) }
  let(:valid_portal_urls) { %w(https://www.europeana.eu/portal/record/123/abc.html https://www.europeana.eu/portal/record/456/def.html) }
  let(:invalid_portal_url) { 'http://www.example.com/' }
  subject { described_class.new(page: page, pref_label: 'C', europeana_ids: europeana_ids) }

  it { is_expected.to have_one(:page_element) }
  it { is_expected.to have_one(:page).through(:page_element) }
  it { is_expected.to validate_presence_of(:europeana_ids) }
  it { is_expected.to validate_presence_of(:pref_label) }

  it { is_expected.to have_array_of_strings_attribute(:portal_urls).elements(valid_portal_urls) }
  it { is_expected.to have_array_of_strings_attribute(:alt_label) }

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

  describe '#query_term_with_fallback' do
    context 'with query_term present' do
      it 'returns it' do
        subject.query_term = 'QT'
        expect(subject.query_term_with_fallback).to eq(subject.query_term)
      end
    end

    context 'without query_term present' do
      context 'with pref_label present' do
        it 'returns it' do
          subject.query_term = nil
          expect(subject.query_term_with_fallback).to eq(subject.pref_label)
        end
      end

      context 'without pref_label present' do
        it 'returns empty string' do
          subject.query_term = nil
          subject.pref_label = nil
          expect(subject.query_term_with_fallback).to eq('')
        end
      end
    end
  end

  describe '#full_query' do
    before do
      page.base_query = base_query
      page.set_query = set_query
    end

    context 'with page base query' do
      let(:base_query) { 'qf[TYPE][]=IMAGE' }

      context 'with per-set query' do
        let(:set_query) { 'q=%{set_query_term}*' }

        it 'combines both' do
          expect(subject.full_query).to eq('qf[TYPE][]=IMAGE&q=C*')
        end
      end

      context 'without per-set query' do
        let(:set_query) { nil }

        it 'combines base query and default query' do
          expect(subject.full_query).to eq('qf[TYPE][]=IMAGE&q=C')
        end
      end
    end
    
    context 'without page base query' do
      let(:base_query) { nil }

      context 'with per-set query' do
        let(:set_query) { 'q=%{set_query_term}*' }

        it 'uses it' do
          expect(subject.full_query).to eq('q=C*')
        end
      end

      context 'without per-set query' do
        let(:set_query) { nil }

        it 'uses default query' do
          expect(subject.full_query).to eq('q=C')
        end
      end
    end
  end

  describe '#formatted_query' do
    before do
      page.set_query = set_query
    end

    context 'when page has per-set query' do
      let(:set_query) { 'q=%{set_query_term}*' }

      it 'inerpolates query_term into it' do
        expect(subject.formatted_query).to eq('q=C*')
      end
    end

    context 'when page has no per-set query' do
      let(:set_query) { nil }

      it 'uses default_query' do
        expect(subject.formatted_query).to eq('q=C')
      end
    end
  end

  describe '#default_query' do
    it 'is "q=" + query_term' do
      expect(subject.default_query).to eq('q=C')
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
