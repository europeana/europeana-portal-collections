RSpec.describe Cache::RecordCounts::DataProvidersJob do
  let(:provider) { 'The European Library' }
  let(:cache_key) { "browse/sources/providers/#{provider}" }

  it 'should fetch data providers from API' do
    subject.perform(provider)
    expect(an_api_search_request).to have_been_made.at_least_once
  end

  it 'should write data providers to cache' do
    Rails.cache.delete(cache_key)
    expect(Rails.cache.fetch(cache_key)).to be_nil
    subject.perform(provider)
    cached = Rails.cache.fetch(cache_key)
    expect(cached).not_to be_nil

    expect(cached).to be_a(Array)
    cached.each do |data_provider|
      expect(data_provider).to include(:text)
      expect(data_provider).to include(:count)
    end
  end

  it 'should accept a collection ID argument' do
    collection_id = Collection.first.id
    subject.perform(provider, collection_id)
    expect(an_api_collection_search_request(collection_id)).to have_been_made.at_least_once
  end
end
