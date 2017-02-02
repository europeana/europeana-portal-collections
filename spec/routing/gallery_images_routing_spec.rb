# frozen_string_literal: true
RSpec.describe 'routes for the gallery images controller' do
  it 'routes GET /en/explore/galleries/high-heels/images/2 to gallery_images#show' do
    expect(get('/en/explore/galleries/high-heels/images/2')).to route_to('gallery_images#show', locale: 'en', gallery_slug: 'high-heels', position: '2')
  end
end
