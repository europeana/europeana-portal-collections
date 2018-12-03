# frozen_string_literal: true

RSpec.describe ThumbnailHelper do
  let(:api_url) { 'http://api.example.com' }
  let(:api_path) { '/v2/thumbnail-by-url.json' }

  let(:cgi_escaped_uri) { 'http%3A%2F%2Fwww.example.org%2Fimage.jpeg' }
  let(:edm_preview) { "http://europeanastatic.eu/image?uri=#{cgi_escaped_uri}&type=TEXT" }

  before do
    allow(helper).to receive(:api_url) { api_url }
  end

  describe '#thumbnail_url_for_edm_preview' do
    subject { helper.thumbnail_url_for_edm_preview(edm_preview) }

    context 'with edm:preview' do
      it 'builds a thumbnail API URL' do
        expect(helper).to receive(:api_thumbnail_url_for_edm_preview).with(edm_preview, {})
        subject
      end
    end

    context 'without edm:preview' do
      let(:edm_preview) { nil }
      it 'makes a generic URL' do
        expect(helper).to receive(:api_thumbnail_url_for_edm_preview)
        subject
      end
    end
  end

  describe '#api_thumbnail_url_for_edm_preview' do
    subject { helper.api_thumbnail_url_for_edm_preview(edm_preview, options) }
    let(:options) { {} }

    context 'without edm:preview' do
      let(:edm_preview) { nil }
      let(:options) { { type: 'IMAGE' } }

      it 'makes a generic URL' do
        expect(subject).to eq(api_url + api_path + '?size=w400&type=IMAGE&uri=')
      end
    end

    context 'with edm:preview' do
      it 'uses the thumbnail API' do
        expect(subject).to match(/^#{api_url}#{api_path}\?/)
      end

      it "uses edm:preview's type and uri params" do
        expect(subject).to match(/[?&]uri=#{cgi_escaped_uri}(&|$)/)
        expect(subject).to match(/[?&]type=TEXT(&|$)/)
      end

      context 'with no size param' do
        it 'defaults to w400' do
          expect(subject).to match(/[?&]size=w400(&|$)/)
        end
      end

      context 'with size param' do
        let(:edm_preview) { "http://europeanastatic.eu/image?uri=#{cgi_escaped_uri}&size=200" }
        it 'prefixes it with "w"' do
          expect(subject).to match(/[?&]size=w200(&|$)/)
        end
      end

      context 'with legacy textual size param "LARGE"' do
        let(:edm_preview) { "http://europeanastatic.eu/image?uri=#{cgi_escaped_uri}&size=LARGE" }
        it 'converts it to "w400"' do
          expect(subject).to match(/[?&]size=w400(&|$)/)
        end
      end
    end
  end

  describe '#api_thumbnail_url' do
    subject { helper.api_thumbnail_url(options) }

    let(:options) { { uri: 'http://www.example.com/music.mp3', type: 'AUDIO', size: 200 } }

    it 'uses options as query parameters' do
      expect(subject).to eq(api_url + api_path + '?size=w200&type=AUDIO&uri=http%3A%2F%2Fwww.example.com%2Fmusic.mp3')
    end
  end

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
