RSpec.describe 'routes for the portal controller' do
  it 'routes GET /en/search to portal#index' do
    expect(get('/en/search')).to route_to('portal#index', locale: 'en')
  end

  it 'routes GET /en/record/:id to portal#show' do
    expect(get('/en/record/abc/123')).to route_to('portal#show', locale: 'en', id: 'abc/123')
  end

  it 'routes POST /en/record/:id/track to portal#track' do
    expect(post('/en/record/abc/123/track')).to route_to('portal#track', locale: 'en', id: 'abc/123')
  end

  it 'routes GET /en/record/:id/similar to portal#similar' do
    expect(get('/en/record/abc/123/similar')).to route_to('portal#similar', locale: 'en', id: 'abc/123')
  end

  it 'routes GET /en/record/:id/media to portal#media' do
    expect(get('/en/record/abc/123/media')).to route_to('portal#media', locale: 'en', id: 'abc/123')
  end

  it 'routes GET /en/record/:id/galleries to portal#galleries' do
    expect(get('/en/record/abc/123/galleries')).to route_to('portal#galleries', locale: 'en', id: 'abc/123')
  end

  it 'routes GET /en/record/:id/annotations to portal#annotations' do
    expect(get('/en/record/abc/123/annotations')).to route_to('portal#annotations', locale: 'en', id: 'abc/123')
  end
end
