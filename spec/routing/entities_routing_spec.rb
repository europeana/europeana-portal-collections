# frozen_string_literal: true

RSpec.describe 'routes for the entities controller' do
  it 'routes GET /en/entities/suggest to entities#suggest' do
    expect(get('/en/entities/suggest')).to route_to('entities#suggest', locale: 'en')
  end

  it 'routes GET /en/explore/:type/:id-:slug.html to entities#show' do
    expect(get('/en/explore/people/146987-leonard-bernstein.html')).
      to route_to('entities#show', locale: 'en', type: 'people', id: '146987',
                                   slug: 'leonard-bernstein', format: 'html')
  end

  it 'routes GET /en/explore/:type/:id.html to entities#show' do
    expect(get('/en/explore/people/146987.html')).
      to route_to('entities#show', locale: 'en', type: 'people', id: '146987', format: 'html')
  end
end
