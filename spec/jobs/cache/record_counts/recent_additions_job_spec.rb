RSpec.describe Cache::RecordCounts::RecentAdditionsJob do
  it 'should fetch providers from API' do
    subject.perform
    expect(an_api_search_request).to have_been_made.at_least_once
  end

  it 'should write providers to cache' do
    Rails.cache.delete('browse/new_content/providers')
    expect(Rails.cache.fetch('browse/new_content/providers')).to be_nil
    subject.perform
    expect(Rails.cache.fetch('browse/new_content/providers')).not_to be_nil
  end

  it 'should accept a collection ID argument' do
    collection_id = Collection.first.id
    subject.perform(collection_id)
    expect(an_api_collection_search_request(collection_id)).to have_been_made.at_least_once
  end
end
