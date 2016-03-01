RSpec.describe 'BrowseController routes' do
  it 'routes GET /browse/newcontent to browse#new_content' do
    expect(get('/browse/newcontent')).to route_to('browse#new_content')
  end

  it 'routes GET /browse/colours to browse#colours' do
    expect(get('/browse/colours')).to route_to('browse#colours')
  end

  it 'routes GET /browse/sources to browse#sources' do
    expect(get('/browse/sources')).to route_to('browse#sources')
  end

  it 'routes GET /browse/people to browse#people' do
    expect(get('/browse/people')).to route_to('browse#people')
  end

  it 'routes GET /browse/topics to browse#topics' do
    expect(get('/browse/topics')).to route_to('browse#topics')
  end
end
