RSpec.describe 'BrowseController routes' do
  it 'routes GET /browse/newcontent to browse#new_content' do
    expect(get(relative_url_root + '/browse/newcontent')).to route_to('browse#new_content')
  end
end
