# frozen_string_literal: true

require 'support/shared_examples/jobs'

shared_examples 'record count caching job' do
  it_behaves_like 'a caching job'
  it_behaves_like 'an API requesting job'

  it 'should write record counts to cache' do
    subject.perform(*args)
    cached = Rails.cache.fetch(cache_key)
    expect(cached).to be_a(Integer)
  end
end

RSpec.describe Cache::RecordCountsJob do
  context 'without collection ID' do
    let(:cache_key) { 'record/counts/all' }
    let(:args) {}
    let(:api_request) { an_api_search_request }

    it_behaves_like 'record count caching job'
  end

  context 'with collection ID' do
    let(:collection) { Collection.published.first }
    let(:cache_key) { "record/counts/collections/#{collection.key}" }
    let(:args) { collection.id }
    let(:api_request) { an_api_collection_search_request(collection.id) }

    it_behaves_like 'record count caching job'

    it 'should touch the landing page' do
      expect { subject.perform(*args) }.to change { collection.landing_page.reload.updated_at }
    end
  end

  context 'with `types` option = true' do
    let(:cache_key) { 'record/counts/all' }
    let(:args) { [nil, types: true] }
    let(:api_request) { an_api_search_request.with(query: hash_including(query: 'TYPE:IMAGE')) }

    it_behaves_like 'record count caching job'
  end
end
