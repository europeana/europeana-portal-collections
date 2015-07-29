require 'rails_helper'

RSpec.describe 'routes for the channels controller', :type => :routing do
  it 'routes GET /channels to channels#index' do
    expect(get(relative_url_root + '/channels')).to route_to('channels#index')
  end

  it 'routes GET /channels/:id to channels#show' do
    expect(get(relative_url_root + '/channels/art')).to route_to('channels#show', id: 'art')
  end
end
