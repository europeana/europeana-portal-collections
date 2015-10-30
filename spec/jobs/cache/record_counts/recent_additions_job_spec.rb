RSpec.describe Cache::RecordCounts::RecentAdditionsJob do
  it 'should fetch providers from API' do
    subject.perform
    expect(an_api_search_request).to have_been_made.at_least_once
  end

  it 'should fetch per-collection providers from API'

  it 'should write providers to cache' do
    Rails.cache.delete('browse/new_content/providers')
    expect(Rails.cache.fetch('browse/new_content/providers')).to be_nil
    subject.perform
    expect(Rails.cache.fetch('browse/new_content/providers')).not_to be_nil
  end
end
