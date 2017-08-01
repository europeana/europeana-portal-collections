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

  describe 'hooks' do
    subject { described_class.new(url: 'http://blog.europeana.eu/', name: 'blog') }

    context 'when saving' do
      it 'should queue the retrieval job for the feed data' do
        expect(subject).to receive(:queue_retrieval) { true }
        subject.run_callbacks :save
      end
    end
  end

  describe 'html_url' do
    context 'when the feed is a tumblr feed' do
      let(:feed) { feeds(:fashion_tumblr) }
      it 'should remove the "/rss" part from the feed url' do
        expect(feed.html_url).to eq 'http://europeanafashion.tumblr.com'
      end
    end

    context 'when the feed is a europeana blog feed' do
      let(:feed) { feeds(:all_blog) }
      it 'should remove the "/feed" part from the feed url' do
        expect(feed.html_url).to eq 'http://blog.europeana.eu/'
      end
    end
  end

  describe '#queue_retrieval' do
    subject { described_class.new(url: 'http://blog.europeana.eu/', name: 'blog') }
    it 'should queue a FeedJob' do
      feed_jobs = proc do
        Delayed::Job.where("handler LIKE '%job_class: Cache::FeedJob%'")
      end
      expect { subject.send(:queue_retrieval) }.to change { feed_jobs.call.count }.by(1)
    end
  end

  describe '#cache_key' do
    let(:feed) { feeds(:fashion_tumblr) }
    it 'should prepend "feed/" to the url' do
      expect(feed.cache_key).to eq "feed/#{feed.url}"
    end
  end
end
