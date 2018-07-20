# frozen_string_literal: true

RSpec.describe Europeana::Record do
  it 'includes Annotations' do
    expect(described_class).to include(Europeana::Record::Annotations)
  end

  let(:id) { '/123/abc' }
  subject { described_class.new(id) }

  let(:api_url) { "#{Europeana::API.url}/v2/record#{id}.json-ld" }
  let(:api_response_status) { 200 }
  let(:api_response_headers) { { 'Content-Type' => 'application/json' } }
  let(:api_response_body) { api_responses(:record, format: 'json-ld', id: id) }

  before(:each) do
    stub_request(:get, api_url).
      with(query: hash_including(wskey: Europeana::API.key)).
      to_return(status: api_response_status, headers: api_response_headers, body: api_response_body)
  end

  describe '.id?' do
    subject { described_class.id?(id) }

    context 'with valid Europeana record ID' do
      let(:id) { '/9200303/BibliographicResource_3000059947163' }
      it { is_expected.to be true }
    end

    %w(
      /9200303/BibliographicResource_3000059947163.html
      9200303/BibliographicResource_3000059947163
      /9200303a/BibliographicResource_3000059947163
      /item/9200303/BibliographicResource_3000059947163
    ).each do |id|
      context %(with invalid Europeana record ID "#{id}") do
        let(:id) { id }
        it { is_expected.to be false }
      end
    end
  end

  describe '.id_from_portal_url' do
    %w(
      http://www.europeana.eu/portal/record/123/abc.html
      http://www.europeana.eu/portal/record/123/abc
      https://www.europeana.eu/portal/record/123/abc.html
      https://www.europeana.eu/portal/record/123/abc
      http://www.europeana.eu/portal/en/record/123/abc.html
      https://www.europeana.eu/portal/de/record/123/abc
    ).each do |url|
      context %(when URL is "#{url}") do
        it 'should extract ID from URL' do
          expect(described_class.id_from_portal_url(url)).to eq('/123/abc')
        end
      end
    end
  end

  describe '.search_api_query_for_record_ids' do
    subject { described_class.search_api_query_for_record_ids(record_ids) }
    let(:record_ids) { %w(/123/abc /def/456) }

    it 'constructs an API search query term' do
      expect(subject).to eq('europeana_id:("/123/abc" OR "/def/456")')
    end
  end

  describe '#portal_url' do
    it 'should construct portal URL from Europeana ID' do
      expect(subject.portal_url).to eq('https://www.europeana.eu/portal/record/123/abc.html')
    end
  end

  describe '#rdf' do
    it 'queries the API' do
      subject.rdf
      expect(a_request(:get, api_url).with(query: hash_including(wskey: Europeana::API.key))).
        to have_been_made.once
    end

    context 'when API response is valid JSON-LD' do
      it 'returns RDF graph from API JSON-LD' do
        expect(subject.rdf).to be_a(RDF::Graph)
      end
    end

    context 'when API response is not valid JSON-LD' do
      let(:api_response_body) { api_responses(:record_not_found, id: id) }
      it 'returns nil' do
        expect(subject.rdf).to be_nil
      end
    end
  end

  describe '#api_json_ld_uri' do
    it 'constructs API URI for record as JSON-LD' do
      expect(subject.api_json_ld_uri).to eq(URI.parse(api_url + "?wskey=#{Europeana::API.key}"))
    end
  end

  describe '#edm_is_shown_by_uri' do
    it "is the record's edm:isShownBy RDF URI" do
      expect(subject.edm_is_shown_by_uri).to eq(RDF::URI.parse("https://media.example.org/isShownBy#{id}.jpg"))
    end
  end

  describe '#edm_has_view_uris' do
    it "is the record's edm:hasView RDF URIs" do
      expect(subject.edm_has_view_uris).to eq([RDF::URI.parse("https://media.example.org/hasView#{id}.jpg")])
    end
  end
end
