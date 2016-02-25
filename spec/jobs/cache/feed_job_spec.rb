RSpec.describe Cache::FeedJob do
  before(:each) do
    stub_request(:get, url).
      to_return(body: rss_body,
                status: 200,
                headers: { 'Content-Type' => 'application/rss+xml' })
  end

  let(:url) { 'http://www.example.com/feed/' }
  let(:rss_body) { <<-END
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
        </item>
      </channel>
    </rss>
    END
  }

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
end
