# frozen_string_literal: true

RSpec.describe 'routes for the application controller' do
  it 'routes GET /status to application#status' do
    expect(get('/status')).to route_to('application#status')
  end
end
