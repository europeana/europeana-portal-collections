# frozen_string_literal: true

RSpec.describe MediaProxyHelper do
  before do
    Rails.application.config.x.europeana_media_proxy = europeana_media_proxy
  end

  describe '#media_proxy_configured?' do
    subject { helper.media_proxy_configured? }

    context 'when media proxy is configured' do
      let(:europeana_media_proxy) { 'http://proxy.example.com' }
      it { is_expected.to be true }
    end

    context 'when media proxy is not configured' do
      let(:europeana_media_proxy) { nil }
      it { is_expected.to be false }
    end
  end

  describe '#media_proxy_url' do
    let(:record_id) { '/abc/123' }
    let(:web_resource_url) { 'http://www.example.com/image.jpg' }

    subject { helper.media_proxy_url(record_id, web_resource_url) }

    context 'when media proxy is configured' do
      let(:europeana_media_proxy) { 'http://proxy.example.com' }
      it 'should use media proxy' do
        expect(subject).to eq('http://proxy.example.com/abc/123?view=http%3A%2F%2Fwww.example.com%2Fimage.jpg')
      end
    end

    context 'when media proxy is not configured' do
      let(:europeana_media_proxy) { nil }
      it 'should be web resource URL' do
        expect(subject).to eq('http://www.example.com/image.jpg')
      end
    end
  end
end
