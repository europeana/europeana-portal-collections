RSpec.describe Cache::FeedJob do
  before(:each) do
    stub_request(:get, url).
      to_return(body: rss_body,
                status: 200,
                headers: { 'Content-Type' => 'application/rss+xml' })
  end

  let(:url) { 'http://www.example.com/feed/' }
  let(:rss_body) do
    <<-END
<?xml version="1.0"?>
<rss version="2.0">
  <channel>
    <title>Example Channel</title>
    <link>http://example.com/</link>
    <description>My example channel</description>
    <item>
       <title>Example item</title>
       <link>http://example.com/item</link>
       <description>About the example item...</description>
       <content:encoded><![CDATA[<img src="http://www.example.com/image.png"/>]]></content:encoded>
    </item>
  </channel>
</rss>
    END
  end

  it 'should fetch an HTTP feed' do
    subject.perform(url)
    expect(a_request(:get, url)).to have_been_made.at_least_once
  end

  it 'should cache the feed' do
    cache_key = "feed/#{url}"
    Rails.cache.delete(cache_key)
    subject.perform(url)
    cached = Rails.cache.fetch(cache_key)
    expect(cached).to be_a(Feedjira::Parser::RSS)
    expect(cached.feed_url).to eq(url)
  end

  context 'when the download_media argument is passed as true' do
    it 'should queue DownloadRemoteMediaObjectJob' do
      download_jobs = proc do
        Delayed::Job.where("handler LIKE '%job_class: DownloadRemoteMediaObjectJob%'")
      end
      expect { subject.perform(url, true) }.to change { download_jobs.call.count }.by_at_least(1)
      expect(download_jobs.call.last.handler).to match(%r{http://www.example.com/image.png})
    end
  end
end
