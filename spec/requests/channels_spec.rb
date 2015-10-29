RSpec.describe 'requests for the /channels path' do
  it 'redirects GET /channels to /collections' do
    get('/channels')
    expect(response).to redirect_to('/collections')
  end

  it 'redirects GET /channels/:id to /collections/:id' do
    get('/channels/music')
    expect(response).to redirect_to('/collections/music')
  end
end
