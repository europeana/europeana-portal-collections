# frozen_string_literal: true

RSpec.describe GalleryImage::HTTPResponse do
  include MediaProxyHelper

  subject { GalleryImage.new(europeana_record_id: europeana_record_id, url: url) }

  let(:europeana_record_id) { '/abc/123' }
  let(:url) { "https://media.example.org#{europeana_record_id}.jpg" }
  let(:http_url) { media_proxy_url(europeana_record_id, url) }
  let(:http_head_response_status) { 200 }
  let(:http_head_response_headers) { { 'Content-Type' => 'image/jpeg' } }
  let(:http_get_response_status) { 200 }
  let(:http_get_response_headers) { { 'Content-Type' => 'image/jpeg' } }


  before(:each) do
    stub_request(:head, http_url).
      to_return(status: http_head_response_status, headers: http_head_response_headers)
    stub_request(:get, http_url).
      to_return(status: http_get_response_status, headers: http_get_response_headers)
  end

  describe '#validate_http_image' do
    it_behaves_like 'may validate may not', :http_response, :validate_http_image

    it 'attempts an HTTP HEAD request to the media proxy' do
      subject.validate_http_image
      expect(a_request(:head, http_url)).to have_been_made.once
    end

    context 'when HTTP HEAD succeeds' do
      it 'makes no HTTP GET request to the media proxy' do
        subject.validate_http_image
        expect(a_request(:get, http_url)).not_to have_been_made
      end
    end

    context 'when HTTP HEAD fails' do
      let(:http_head_response_status) { 405 }

      it 'attempts an HTTP GET request to the media proxy' do
        subject.validate_http_image
        expect(a_request(:get, http_url)).to have_been_made.once
      end
    end

    context 'when resource is not found' do
      let(:http_head_response_status) { 404 }
      let(:http_get_response_status) { 404 }

      it 'is invalid' do
        subject.validate_http_image
        expect(subject.errors[:url]).not_to be_blank
      end
    end

    context 'when resource is not an image' do
      let(:http_head_response_headers) { { 'Content-Type' => 'application/pdf' } }

      it 'is invalid' do
        subject.validate_http_image
        expect(subject.errors[:url]).not_to be_blank
      end
    end

    context 'when resource is an image' do
      it 'is valid' do
        subject.validate_http_image
        expect(subject.errors[:url]).to be_blank
      end
    end
  end
end
