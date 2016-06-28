RSpec.describe 'redirects for the /browse path' do
  it 'redirects GET /en/browse/agents to /browse/people' do
    get('/en/browse/agents')
    expect(response).to redirect_to('/browse/people')
  end

  it 'redirects GET /en/browse/concepts to /browse/topics' do
    get('/en/browse/concepts')
    expect(response).to redirect_to('/browse/topics')
  end
end
