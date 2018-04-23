# frozen_string_literal: true

RSpec.describe Cache::FeedJob do
  before(:each) do
    stub_request(:get, url).
      to_return(body: rss_body,
                status: 200,
                headers: { 'Content-Type' => 'application/rss+xml' })
  end

  let(:url) { feeds(:all_blog).url }
  let(:rss_body) do
    <<~END
      <?xml version="1.0"?>
      <rss version="2.0">
        <channel>
          <title>Example Channel</title>
          <link>http://example.com/</link>
          <description>My example channel</description>
          <lastBuildDate>Mon, 22 May 2017 00:00:00 +0000</lastBuildDate>
          <item>
             <title>Example item</title>
             <link>http://example.com/item</link>
             <description>About the example item...</description>
             <content:encoded><![CDATA[<img src="http://www.example.com/image.png"/>]]></content:encoded>
             <pubDate>Mon, 22 May 2017 00:00:00 +0000</pubDate>
          </item>
        </channel>
      </rss>
    END
  end
  let(:cache_key) { "feed/#{url}" }

  it 'should fetch an HTTP feed' do
    subject.perform(url)
    expect(a_request(:get, url)).to have_been_made.at_least_once
  end

  it 'should cache the feed' do
    Rails.cache.delete(cache_key)
    described_class.perform_now(url)
    cached = Rails.cache.fetch(cache_key)
    expect(cached).to be_a(Feedjira::Parser::RSS)
    expect(cached.feed_url).to eq(url)
  end

  context 'when the feed was updated' do
    before do
      Rails.cache.write(cache_key, Feedjira::Feed.parse(rss_body.gsub('Mon, 22 May 2017', 'Tue, 23 May 2017')))
    end
    it 'should queue DownloadRemoteMediaObjectJob' do
      expect { described_class.perform_now(url) }.to have_enqueued_job(DownloadRemoteMediaObjectJob).with('http://www.example.com/image.png').at_least(:once)
    end
  end

  context 'when the feed was NOT updated' do
    before do
      Rails.cache.write(cache_key, Feedjira::Feed.parse(rss_body))
    end
    it 'should not queue DownloadRemoteMediaObjectJob' do
      expect { described_class.perform_now(url) }.not_to have_enqueued_job(DownloadRemoteMediaObjectJob)
    end
  end

  context 'when the feed was previously cached' do
    before do
      Rails.cache.write(cache_key, Feedjira::Feed.parse(rss_body))
    end

    context 'when the last_modified date has NOT changed' do
      it 'should not update the cache and @updated should be false' do
        expect(Rails.cache).to_not receive(:write)
        expect { subject.perform(url) }.to_not change { Rails.cache.fetch(cache_key) }
        expect(subject.instance_variable_get(:@updated)).to_not eq(true)
      end
    end

    context 'when the last_modified date has changed' do
      before do
        Rails.cache.write(cache_key, Feedjira::Feed.parse(rss_body.gsub('Mon, 22 May 2017', 'Tue, 23 May 2017')))
      end

      it 'should update the cache and @updated should be true' do
        expect { subject.perform(url) }.to change { Rails.cache.fetch(cache_key) }
        expect(subject.instance_variable_get(:@updated)).to eq(true)
      end
    end
  end
end
