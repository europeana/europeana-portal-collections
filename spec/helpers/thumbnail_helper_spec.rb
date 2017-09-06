# frozen_string_literal: true

RSpec.describe ThumbnailHelper do
  describe '#thumbnail_url_for_edm_preview'
  describe '#api_thumbnail_url_for_edm_preview'

  describe '#api_thumbnail_url' do
    subject { helper.api_thumbnail_url(options) }

    let(:options) { { uri: 'http://www.example.com/', type: 'AUDIO', size: 200 } }

    it 'uses options as query parameters' do
      allow(helper).to receive(:api_url) { 'http://api.example.com' }
      expect(subject).to eq('http://api.example.com/v2/thumbnail-by-url.json?size=w200&type=AUDIO&uri=http%3A%2F%2Fwww.example.com%2F')
    end
  end

  describe '#s3_thumbnail_url_for_edm_preview'

  describe '#thumbnail_url_options_with_size' do
    subject { helper.thumbnail_url_options_with_size(options)[:size] }

    context 'without size' do
      let(:options) { { type: 'IMAGE' } }
      it { is_expected.to eq(400) }
    end

    context 'when size is "LARGE"' do
      let(:options) { { size: 'LARGE' } }
      it { is_expected.to eq(400) }
    end

    context 'when size is "MEDIUM"' do
      let(:options) { { size: 'MEDIUM' } }
      it { is_expected.to eq(200) }
    end
  end
end
