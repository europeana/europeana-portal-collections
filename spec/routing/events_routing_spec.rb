# frozen_string_literal: true

RSpec.describe 'routes for the events controller' do
  it 'routes GET /en/events to events#index' do
    expect(get('/en/events')).to route_to('events#index', locale: 'en')
  end

  it 'routes GET /en/events/conference to events#show' do
    expect(get('/en/events/conference')).to route_to('events#show', locale: 'en', slug: 'conference')
  end
end
