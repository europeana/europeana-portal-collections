require 'rails_helper'

RSpec.describe 'routes for Channels', :type => :routing do
  it 'routes / to channels#index' do
    expect(get('/')).to route_to('channels#index')
  end

  it 'routes /channels to channels#index' do
    expect(get('/channels')).to route_to('channels#index')
  end

  it 'routes /channels/:id to channels#show' do
    expect(get('/channels/art')).to route_to('channels#show', id: 'art')
  end
end
