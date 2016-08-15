RSpec.describe 'explore/new_content.html.mustache', :common_view_components do
  let(:providers) do
    time_now = Time.zone.now
    [
      { label: 'A Provider', count: 1000, from: time_now },
      { label: 'Another Provider', count: 2000, from: time_now },
      { label: 'A Different Provider', count: 500, from: time_now }
    ]
  end

  it 'should have page title' do
    render
    expect(rendered).to have_selector('title', visible: false, text: /new/i)
  end

  it 'should have meta description' do
    render
    expect(rendered).to have_selector("meta[name=\"description\"]", visible: false)
  end

  it 'should display a list of data providers' do
    assign(:providers, providers)
    render
    providers.each do |provider|
      expect(rendered).to have_selector('ul li a', text: provider[:text])
    end
  end
end
