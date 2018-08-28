# frozen_string_literal: true

RSpec.describe Europeana::Record::Hierarchies do
  describe '.europeana_ancestor?' do
    subject { described_class.europeana_ancestor?(dcterms_has_part) }

    context 'when dcterms_has_part is blank' do
      let(:dcterms_has_part) { [] }
      it { is_expected.to be false }
    end

    context 'when dcterms_has_part has only non-data.europeana.eu URIs' do
      let(:dcterms_has_part) { %w(http://www.example.com/item/123/abc) }
      it { is_expected.to be false }
    end

    context 'when dcterms_has_part has mostly non-data.europeana.eu URIs' do
      let(:dcterms_has_part) { %w(http://www.example.com/item/123/abc http://www.example.com/item/123/def http://data.europeana.eu/item/123/abc) }
      it { is_expected.to be false }
    end

    context 'when dcterms_has_part has half data.europeana.eu URIs' do
      let(:dcterms_has_part) { %w(http://www.example.com/item/123/abc http://data.europeana.eu/item/123/abc) }
      it { is_expected.to be false }
    end

    context 'when dcterms_has_part has mostly data.europeana.eu URIs' do
      let(:dcterms_has_part) { %w(http://www.example.com/item/123/abc http://data.europeana.eu/item/123/abc http://data.europeana.eu/item/123/def) }
      it { is_expected.to be true }
    end

    context 'when dcterms_has_part has only data.europeana.eu URIs' do
      let(:dcterms_has_part) { %w(http://data.europeana.eu/item/123/abc http://data.europeana.eu/item/123/def) }
      it { is_expected.to be true }
    end
  end
end
