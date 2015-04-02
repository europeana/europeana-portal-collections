require 'rails_helper'

RSpec.describe 'routes for Blacklight documents', :type => :routing do
  it 'routes /record/:provider_id/:record_id.html to catalog#show' do
    expect(get('/record/abc/123.html')).to route_to('catalog#show', provider_id: 'abc', record_id: '123', format: 'html')
  end

  it 'routes /record/:provider_id/:record_id/track to catalog#track' do
    expect(post('/record/abc/123/track')).to route_to('catalog#track', provider_id: 'abc', record_id: '123')
  end
end
