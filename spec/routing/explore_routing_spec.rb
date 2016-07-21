RSpec.describe 'ExploreController routes' do
  it 'routes GET /en/explore/newcontent to explore#new_content' do
    expect(get('/en/explore/newcontent')).to route_to('explore#new_content', locale: 'en')
  end

  it 'routes GET /en/explore/colours to explore#colours' do
    expect(get('/en/explore/colours')).to route_to('explore#colours', locale: 'en')
  end

  it 'routes GET /en/explore/sources to explore#sources' do
    expect(get('/en/explore/sources')).to route_to('explore#sources', locale: 'en')
  end

  it 'routes GET /en/explore/people to explore#people' do
    expect(get('/en/explore/people')).to route_to('explore#people', locale: 'en')
  end

  it 'routes GET /en/explore/topics to explore#topics' do
    expect(get('/en/explore/topics')).to route_to('explore#topics', locale: 'en')
  end
end
