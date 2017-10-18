# frozen_string_literal: true

RSpec.describe Cache::Expiry::FeedAssociatedJob do
  let(:url) { 'https://blog.europeana.eu/test/feed'}

  context 'when the feed is used in the Navigation' do
    before do
      allow(NavigableView).to receive(:feeds_included_in_nav_urls) { [url] }
    end

    it 'enqueues a GLobalNav Expiry job' do
      global_nav_job_count = Proc.new do
          Delayed::Job.where("handler LIKE '%job_class: Cache::Expiry::GlobalNavJob%'").count
      end
      expect { subject.perform(url) }.to change { global_nav_job_count.call }.by_at_least(1)
    end
  end

  context 'when the feed is used as a news feed for a landing page' do
    let(:url) { pages(:home).feeds.first.url }
    it 'enqueues a Page Expiry job' do
      page_job_count = Proc.new do
        Delayed::Job.where("handler LIKE '%job_class: Cache::Expiry::PageJob%'").count
      end
      expect { subject.perform(url) }.to change { page_job_count.call }.by_at_least(1)
    end
  end
end
