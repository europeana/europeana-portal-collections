RSpec.describe 'redirects for the /browse path' do
  it 'redirects GET /en/browse/agents to /en/browse/people' do
    get('/en/browse/agents')
    expect(response).to redirect_to('/en/browse/people')
  end

  it 'redirects GET /en/browse/concepts to /en/browse/topics' do
    get('/en/browse/concepts')
    expect(response).to redirect_to('/en/browse/topics')
  end
end
