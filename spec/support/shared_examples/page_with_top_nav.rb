RSpec.shared_examples 'page with top nav' do
  it 'should have top nav link to home' do
    render
    expect(rendered).to have_selector("#main-menu a", text: 'Home')
  end

  it 'should have top nav links to published channels' do
    render
    expect(rendered).to have_selector("#main-menu a[href$=\"/channels/music\"]", text: 'Europeana Music')
  end
end
