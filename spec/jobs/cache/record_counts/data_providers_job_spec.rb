require 'support/shared_examples/jobs'

shared_examples 'data provider record count caching job' do
  it_behaves_like 'a caching job'
  it_behaves_like 'an API requesting job'

  it 'should write data provider record counts to cache' do
    subject.perform(*args)
    cached = Rails.cache.fetch(cache_key)
    expect(cached).to be_a(Array)
    cached.each do |data_provider|
      expect(data_provider).to include(:text)
      expect(data_provider).to include(:count)
    end
  end
end

RSpec.describe Cache::RecordCounts::DataProvidersJob do
  let(:provider) { 'The European Library' }

  context 'without collection ID' do
    let(:cache_key) { "browse/sources/providers/#{provider}" }
    let(:args) { provider }
    let(:api_request) { an_api_search_request }

    it_behaves_like 'data provider record count caching job'
  end

  context 'with collection ID' do
    let(:collection) { Collection.published.first }
    let(:cache_key) { "browse/sources/providers/#{collection.key}/#{provider}" }
    let(:args) { [provider, collection.id] }
    let(:api_request) { an_api_collection_search_request(collection.id) }

    it_behaves_like 'data provider record count caching job'
  end
end
