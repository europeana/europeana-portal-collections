RSpec.describe 'rewritten search requests' do
  it 'rewrites old search params to new and redirects' do
    relative_url_root = Europeana::Portal::Application.config.relative_url_root
    get('/search.html?query=japan&rows=24&start=25&qf=TYPE%3AIMAGE&qf=LANGUAGE%3Anl&qf=tokyo')
    expect(response).to redirect_to(relative_url_root + '/search?qf[]=tokyo&q=japan&page=3&f[TYPE][]=IMAGE&f[LANGUAGE][]=nl')
  end
end
