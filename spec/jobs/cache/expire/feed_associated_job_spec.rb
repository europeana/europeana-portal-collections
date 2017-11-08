# frozen_string_literal: true

RSpec.describe Cache::Expiry::FeedAssociatedJob do
  let(:url) { 'https://blog.europeana.eu/test/feed' }

  context 'when the feed is used in the Navigation' do
    before do
      allow(NavigableView).to receive(:feeds_included_in_nav_urls) { [url] }
    end

    it 'enqueues a GLobalNav Expiry job' do
      expect { subject.perform(url) }.to have_enqueued_job(Cache::Expiry::GlobalNavJob)
    end
  end

  context 'when the feed is used as a news feed for a landing page' do
    let(:url) { pages(:home).feeds.first.url }
    it 'enqueues a Page Expiry job' do
      expect { subject.perform(url) }.to have_enqueued_job(Cache::Expiry::PageJob)
    end
  end
end
