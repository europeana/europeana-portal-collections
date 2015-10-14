RSpec.describe 'routes for the settings controller' do
  it 'routes GET /settings/language to settings#language' do
    expect(get('/settings/language')).to route_to('settings#language')
  end

  it 'routes PUT /settings/language to settings#language' do
    expect(put('/settings/language')).to route_to('settings#update_language')
  end
end
