RSpec.describe Cache::RecordCounts::ProvidersJob do
  let(:cache_key) { 'browse/sources/providers' }

  it 'should fetch providers from API' do
    subject.perform
    expect(an_api_search_request).to have_been_made.at_least_once
  end

  it 'should write providers to cache' do
    Rails.cache.delete(cache_key)
    expect(Rails.cache.fetch(cache_key)).to be_nil
    subject.perform
    cached = Rails.cache.fetch(cache_key)
    expect(cached).not_to be_nil

    expect(cached).to be_a(Array)
    cached.each do |provider|
      expect(provider).to include(:text)
      expect(provider).to include(:count)
    end
  end

  it 'should queue data provider jobs' do
    data_providers_job_count = Proc.new do
      Delayed::Job.where("handler LIKE '%job_class: Cache::RecordCounts::DataProvidersJob%'").count
    end
    expect { subject.perform }.to change { data_providers_job_count.call }.by_at_least(1)
  end

  it 'should accept a collection ID argument' do
    collection_id = Collection.first.id
    subject.perform(collection_id)
    expect(an_api_collection_search_request(collection_id)).to have_been_made.at_least_once
  end
end
