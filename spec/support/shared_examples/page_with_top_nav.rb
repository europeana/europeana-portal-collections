RSpec.shared_examples 'page with top nav', :page_with_top_nav do
  it 'should have top nav link to home' do
    render
    expect(rendered).to have_selector('#main-menu a', pages(:home).title)
  end

  it 'should have top nav links to published collections' do
    render
    expect(rendered).to have_selector('#main-menu a[href$="/collections/music"]', text: collections(:music).title)
  end

  it 'should have top nav links to explore pages' do
    render
    expect(rendered).to have_selector('#main-menu a', text: 'Explore')
    expect(rendered).to have_selector('#main-menu a[href$="/browse/newcontent.html"]')
    expect(rendered).to have_selector('#main-menu a[href$="/browse/colours.html"]')
    expect(rendered).to have_selector('#main-menu a[href$="/browse/sources.html"]')
    expect(rendered).to have_selector('#main-menu a[href$="/browse/topics.html"]')
    expect(rendered).to have_selector('#main-menu a[href$="/browse/people.html"]')
  end
end
