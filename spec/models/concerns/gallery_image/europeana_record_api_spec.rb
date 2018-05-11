# frozen_string_literal: true

RSpec.describe GalleryImage::EuropeanaRecordAPI do
  subject { GalleryImage.new(europeana_record_id: europeana_record_id, url: url) }

  let(:europeana_record_id) { '/abc/123' }
  let(:url) { "https://media.example.org#{europeana_record_id}.jpg" }
  let(:api_response_status) { 200 }
  let(:api_response_headers) { { 'Content-Type' => 'application/json' } }
  let(:api_response_body) { api_responses(:record, format: 'json-ld', id: europeana_record_id) }

  before(:each) do
    stub_request(:get, "#{Europeana::API.url}/v2/record#{europeana_record_id}.json-ld").
         with(query: hash_including(wskey: Europeana::API.key)).
         to_return(status: api_response_status, headers: api_response_headers, body: api_response_body)
  end

  describe '#url_from_europeana_record_edm_is_shown_by' do
    context 'without explicit url' do
      let(:url) { nil }

      context 'when validating with europeana_record_api' do
        it 'sets to edm:isShownBy before validation' do
          subject.validating_with(:europeana_record_api) do
            subject.validate
          end
          expect(subject.url).not_to be_nil
        end
      end

      context 'when validating without europeana_record_api' do
        it 'does not set it' do
          subject.validate
          expect(subject.url).to be_nil
        end
      end
    end
  end

  describe '#validate_found_europeana_record_id' do
    it_behaves_like 'may validate may not', :europeana_record_api, :validate_found_europeana_record_id

    context 'when record is found' do
      it 'registers no error on europeana_record_id' do
        subject.validate_found_europeana_record_id
        expect(subject.errors[:europeana_record_id]).to be_blank
      end
    end

    context 'when record is not found' do
      let(:api_response_status) { 404 }
      let(:api_response_body) { api_responses(:record_not_found, id: europeana_record_id) }

      it 'registers an error on europeana_record_id' do
        subject.validate_found_europeana_record_id
        expect(subject.errors[:europeana_record_id]).not_to be_blank
      end
    end
  end

  describe '#validate_europeana_record_web_resource' do
    it_behaves_like 'may validate may not', :europeana_record_api, :validate_europeana_record_web_resource

    context 'when url is edm:isShownBy' do
      let(:url) { "https://media.example.org/isShownBy#{europeana_record_id}.jpg" }

      it 'is valid' do
        subject.validate_europeana_record_web_resource
        expect(subject.errors[:url]).to be_blank
      end
    end

    context 'when url is in edm:hasViews' do
      let(:url) { "https://media.example.org/hasView#{europeana_record_id}.jpg" }
      it 'is valid' do
        subject.validate_europeana_record_web_resource
        expect(subject.errors[:url]).to be_blank
      end
    end

    context 'when url is other web resource' do
      let(:url) { "https://media.example.org/webResource#{europeana_record_id}.jpg" }
      it 'is invalid' do
        subject.validate_europeana_record_web_resource
        expect(subject.errors[:url]).not_to be_blank
      end
    end

    context 'when url is not in web resources' do
      it 'is invalid' do
        subject.validate_europeana_record_web_resource
        expect(subject.errors[:url]).not_to be_blank
      end
    end
  end
end
