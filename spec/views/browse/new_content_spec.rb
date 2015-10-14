RSpec.describe 'browse/new_content.html.mustache' do
  let(:providers) do
    time_now = Time.now
    [
      { label: 'A Provider', count: 1000, from: time_now },
      { label: 'Another Provider', count: 2000, from: time_now },
      { label: 'A Different Provider', count: 500, from: time_now }
    ]
  end

  it 'should have page title' do
    render
    expect(rendered).to have_selector('title', visible: false, text: 'New Content')
  end

  it 'should have meta description' do
    meta_content = 'New Content'
    render
    expect(rendered).to have_selector("meta[name=\"description\"][content=\"#{meta_content}\"]", visible: false)
  end

  it 'should display a list of data providers' do
    assign(:providers, providers)
    render
    providers.each do |provider|
      expect(rendered).to have_selector('ul li a', text: provider[:text])
    end
  end
end
