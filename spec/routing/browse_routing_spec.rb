RSpec.describe 'BrowseController routes' do
  it 'routes GET /en/browse/newcontent to browse#new_content' do
    expect(get('/en/browse/newcontent')).to route_to('browse#new_content', locale: 'en')
  end

  it 'routes GET /en/browse/colours to browse#colours' do
    expect(get('/en/browse/colours')).to route_to('browse#colours', locale: 'en')
  end

  it 'routes GET /en/browse/sources to browse#sources' do
    expect(get('/en/browse/sources')).to route_to('browse#sources', locale: 'en')
  end

  it 'routes GET /en/browse/people to browse#people' do
    expect(get('/en/browse/people')).to route_to('browse#people', locale: 'en')
  end

  it 'routes GET /en/browse/topics to browse#topics' do
    expect(get('/en/browse/topics')).to route_to('browse#topics', locale: 'en')
  end
end
