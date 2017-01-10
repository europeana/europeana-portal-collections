# frozen_string_literal: true
RSpec.describe 'routes for the entities controller' do
  it 'routes GET /en/entities/suggest to entities#suggest' do
    expect(get('/en/entities/suggest')).to route_to('entities#suggest', locale: 'en')
  end
end
