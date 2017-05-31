RSpec.describe 'routes for the collections controller' do
  it 'routes GET /en/collections to collections#index' do
    expect(get('/en/collections')).to route_to('collections#index', locale: 'en')
  end

  it 'routes GET /en/collections/:id to collections#show' do
    expect(get('/en/collections/art')).to route_to('collections#show', locale: 'en', id: 'art')
  end

  it 'routes GET /en/collections/music/contribute to collections#ugc' do
    expect(get('/en/collections/music/contribute')).to route_to('collections#ugc', locale: 'en', id: 'music')
  end
end
