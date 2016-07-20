RSpec.shared_examples 'common view components', :common_view_components do
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

  it 'should have x-default alternate link' do
    render
    expect(rendered).to have_selector('link[rel="alternate"][hreflang="x-default"]', visible: false)
  end

  it 'should have alternate links to all locales' do
    class AvailableLocales
      include I18nHelper
    end

    render
    AvailableLocales.new.language_map.keys.each do |locale|
      expect(rendered).to have_selector("link[rel=\"alternate\"][hreflang=\"#{locale}\"]", visible: false)
    end
  end
end
