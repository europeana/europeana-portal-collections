require 'rails_helper'

RSpec.describe 'routes for the portal controller', :type => :routing do
  it 'routes GET /search to portal#index' do
    expect(get('/search')).to route_to('portal#index')
  end

  it 'routes GET /record/:provider_id/:record_id to portal#show' do
    expect(get('/record/abc/123')).to route_to('portal#show', provider_id: 'abc', record_id: '123')
  end

  it 'routes POST /record/:provider_id/:record_id/track to portal#track' do
    expect(post('/record/abc/123/track')).to route_to('portal#track', provider_id: 'abc', record_id: '123')
  end
end
