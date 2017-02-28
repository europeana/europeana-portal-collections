# frozen_string_literal: true
RSpec.describe Feed do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_uniqueness_of(:url) }
  it { is_expected.to have_and_belong_to_many(:pages) }

  it 'should set the slug from the name' do
    feed = Feed.create(name: 'Art Tumblr')
    expect(feed.slug).to eq('art-tumblr')
  end

  describe '#to_param' do
    it 'should return the slug' do
      feed = Feed.create(name: 'Art Tumblr', slug: 'art-tumblr')
      expect(feed.to_param).to eq('art-tumblr')
    end
  end

  describe '#url_in_domain?' do
    context 'when URL is "http://www.europeana.eu/"' do
      let(:url) { 'http://www.europeana.eu/' }

      context 'domain is europeana.eu' do
        subject { described_class.new(url: url).url_in_domain?('europeana.eu') }
        it { is_expected.to be true }
      end

      context 'domain is europeana.com' do
        subject { described_class.new(url: url).url_in_domain?('europeana.com') }
        it { is_expected.to be false }
      end
    end
  end

  describe 'html_url' do
    context 'when the feed is a tumblr feed' do
      let(:feed) { feeds(:fashion_tumblr)}
      it 'should remove the "/rss" part from the feed url' do
        expect(feed.html_url).to eq 'http://europeanafashion.tumblr.com'
      end
    end

    context 'when the feed is a europeana blog feed' do
      let(:feed) { feeds(:all_blog)}
      it 'should remove the "/feed" part from the feed url' do
        expect(feed.html_url).to eq 'http://blog.europeana.eu/'
      end
    end
  end
end
