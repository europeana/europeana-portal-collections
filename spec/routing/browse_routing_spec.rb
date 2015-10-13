RSpec.describe 'BrowseController routes' do
  it 'routes GET /browse/newcontent to browse#new_content' do
    expect(get(relative_url_root + '/browse/newcontent')).to route_to('browse#new_content')
  end

  it 'routes GET /browse/colours to browse#colours' do
    expect(get(relative_url_root + '/browse/colours')).to route_to('browse#colours')
  end

  it 'routes GET /browse/sources to browse#sources' do
    expect(get(relative_url_root + '/browse/sources')).to route_to('browse#sources')
  end
end
