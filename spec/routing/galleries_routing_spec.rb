# frozen_string_literal: true

RSpec.describe 'routes for the galleries controller' do
  it 'routes GET /en/explore/galleries to galleries#index' do
    expect(get('/en/explore/galleries')).to route_to('galleries#index', locale: 'en')
  end

  it 'routes GET /en/explore/galleries/high-heels to galleries#show' do
    expect(get('/en/explore/galleries/high-heels')).to route_to('galleries#show', locale: 'en', slug: 'high-heels')
  end
end
