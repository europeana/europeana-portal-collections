# frozen_string_literal: true

RSpec.describe ThumbnailHelper do
  let(:api_url) { 'http://api.example.com' }
  let(:api_path) { '/v2/thumbnail-by-url.json' }

  before do
    allow(helper).to receive(:api_url) { api_url }
  end

  describe '#thumbnail_url_for_edm_preview'

  describe '#api_thumbnail_url_for_edm_preview' do
    subject { helper.api_thumbnail_url_for_edm_preview(edm_preview, options) }
    let(:options) { { } }

    context 'without edm:preview' do
      let(:edm_preview) { nil }
      let(:options) { { type: 'IMAGE' } }

      it 'makes a generic URL' do
        expect(subject).to eq(api_url + api_path + '?size=w400&type=IMAGE')
      end
    end

    context 'with edm:preview' do
      let(:cgi_escaped_uri) { 'http%3A%2F%2Fbodley30.bodley.ox.ac.uk%3A8081%2FMediaManager%2Fsrvr%3Fmediafile%3D%2FSize4%2FODLodl-1-NA%2F1020%2Fbodl_Mex.d.1_roll113_frame32.jpg%26userid%3D1%26username%3Dinsight%26resolution%3D1%26servertype%3DJVA%26cid%3D1%26iid%3DODLodl%26vcid%3DNA%26usergroup%3DARTstor%26profileid%3D4' }

      let(:edm_preview) { "http://europeanastatic.eu/image?uri=#{cgi_escaped_uri}&type=TEXT" }

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
