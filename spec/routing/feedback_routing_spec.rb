RSpec.describe 'routes for the portal controller' do
  it 'routes POST /en/feedback to feedback#create' do
    expect(post('/en/feedback')).to route_to('feedback#create', locale: 'en')
  end
end
