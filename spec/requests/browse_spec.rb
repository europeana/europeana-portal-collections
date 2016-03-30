RSpec.describe 'redirects for the /browse path' do
  it 'redirects GET /browse/agents to /browse/people' do
    get('/browse/agents')
    expect(response).to redirect_to('/browse/people')
  end

  it 'redirects GET /browse/concepts to /browse/topics' do
    get('/browse/concepts')
    expect(response).to redirect_to('/browse/topics')
  end
end
