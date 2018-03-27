# frozen_string_literal: true

RSpec.describe 'rewritten search requests' do
  let(:relative_url_root) { Europeana::Portal::Application.config.relative_url_root || '' }

  it 'rewrites old search params to new and redirects' do
    get('/search.html?query=japan&rows=24&start=25&qf=TYPE%3AIMAGE&qf=LANGUAGE%3Anl&qf=tokyo')
    expect(response).to redirect_to(relative_url_root + '/search?qf[]=tokyo&q=japan&page=3&f[TYPE][]=IMAGE&f[LANGUAGE][]=nl')
  end

  it 'drops surrounding quote marks from old facet params' do
    get('/search.html?qf=PROVIDER%3A"The+European+Library"')
    expect(response).to redirect_to(relative_url_root + '/search?f[PROVIDER][]=The+European+Library')
  end
end
