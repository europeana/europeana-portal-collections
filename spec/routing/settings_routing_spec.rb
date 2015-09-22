RSpec.describe 'routes for the settings controller' do
  it 'routes GET /settings/language to settings#language' do
    expect(get(relative_url_root + '/settings/language')).to route_to('settings#language')
  end
end
