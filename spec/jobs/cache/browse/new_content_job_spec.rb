RSpec.describe Cache::Browse::NewContentJob do
  it 'should fetch providers from API' do
    subject.perform
    expect(an_api_search_request).to have_been_made.times(24)
  end

  it 'should write providers to cache'
end
