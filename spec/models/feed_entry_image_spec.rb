# frozen_string_literal: true

RSpec.describe FeedEntryImage do
  let(:feed_url) { 'http://www.example.org/feed' }
  let(:image_url) { 'http://www.example.org/file' }
  let(:media_object) { MediaObject.new(source_url: image_url) }

  subject { described_class.new(feed_url) }

  before do
    allow(subject).to receive(:url) { image_url }
  end

  describe '#thumbnail_url' do
    context 'when there is a media object' do
      before do
        allow(subject).to receive(:media_object) {media_object}
      end

      it 'returns the computed url' do
        expect(subject.thumbnail_url).to eq('/files/medium/missing.png')
      end
    end
  end

  describe '#media_object' do
    let(:media_object) { MediaObject.create(source_url: image_url) }

    before do
      # call media object to create it with the hash_source_url
      media_object
    end

    it 'returns the computed url' do
      expect(subject.media_object).to eq(media_object)
    end
  end
end
