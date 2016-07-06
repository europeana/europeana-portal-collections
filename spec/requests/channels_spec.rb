RSpec.describe 'requests for the /en/channels path' do
  it 'redirects GET /en/channels to /en/collections' do
    get('/en/channels')
    expect(response).to redirect_to('/en/collections')
  end

  it 'redirects GET /en/channels/:id to /en/collections/:id' do
    get('/en/channels/music')
    expect(response).to redirect_to('/en/collections/music')
  end
end
