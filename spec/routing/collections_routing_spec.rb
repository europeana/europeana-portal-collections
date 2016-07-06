RSpec.describe 'routes for the collections controller' do
  it 'routes GET /en/collections to collections#index' do
    expect(get('/en/collections')).to route_to('collections#index', locale: 'en')
  end

  it 'routes GET /en/collections/:id to collections#show' do
    expect(get('/en/collections/art')).to route_to('collections#show', locale: 'en', id: 'art')
  end

  it 'routes GET /en/collections/:id/tumblr to collections#tumblr' do
    expect(get('/en/collections/art/tumblr')).to route_to('collections#tumblr', locale: 'en', id: 'art')
  end
end
