require 'rails_helper'

RSpec.describe 'routes for the home controller' do
  it 'routes GET /en to home#index' do
    expect(get('/en')).to route_to('home#index', locale: 'en')
  end
end
