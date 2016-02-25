shared_examples 'a caching job' do
  let(:cached) { Proc.new { Rails.cache.fetch(cache_key) } }

  it 'writes to the cache' do
    Rails.cache.delete(cache_key)
    expect(cached.call).to be_nil
    expect { subject.perform(*args) }.to change { cached.call }
    expect(cached.call).not_to be_nil
  end
end

shared_examples 'an API requesting job' do
  it 'should make an API request' do
    subject.perform(*args)
    expect(api_request).to have_been_made.at_least_once
  end
end
