RSpec.shared_examples 'page with top nav', :page_with_top_nav do
  it 'should have top nav link to home' do
    render
    expect(rendered).to have_selector('#main-menu a', pages(:home).title)
  end

  it 'should have top nav links to published collections' do
    render
    expect(rendered).to have_selector('#main-menu a[href$="/collections/music"]', text: collections(:music).title)
  end
end
