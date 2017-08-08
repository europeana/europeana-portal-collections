RSpec.shared_examples 'common view components', :common_view_components do
  let(:available_locales) do
    [:bg, :ca, :da, :de, :el, :en, :es, :fi, :fr, :hr, :hu, :it, :lt, :lv, :nl, :pl, :pt, :ro, :ru, :sv]
  end

  it 'should have site name in <title>' do
    site_name = I18n.t('site.name')
    render
    expect(rendered).to have_selector('title', text: %r{#{site_name}}, visible: false)
  end

  it 'should have no top nav link to home' do
    render
    expect(rendered).not_to have_selector('#main-menu a[href$="/"]', text: pages(:home).title)
  end

  it 'should have top nav links to published collections' do
    render
    expect(rendered).to have_selector('#main-menu a[href$="/collections/music"]', text: collections(:music).title)
  end

  it 'should have meta referrer tag' do
    render
    expect(rendered).to have_selector('meta[name="referrer"][content="always"]', visible: false)
  end

  it 'should have meta og:site_name tag' do
    render
    expect(rendered).to have_selector('meta[property="og:site_name"][content="Europeana Collections"]', visible: false)
  end

  it 'should have top nav links to explore pages' do
    render
    expect(rendered).to have_selector('#main-menu a', text: 'Explore')
    expect(rendered).to have_selector('#main-menu a[href$="/explore/newcontent.html"]')
    expect(rendered).to have_selector('#main-menu a[href$="/explore/colours.html"]')
    expect(rendered).to have_selector('#main-menu a[href$="/explore/sources.html"]')
    expect(rendered).to have_selector('#main-menu a[href$="/explore/topics.html"]')
    expect(rendered).to have_selector('#main-menu a[href$="/explore/people.html"]')
  end

  it 'should have x-default alternate link' do
    render
    expect(rendered).to have_selector('link[rel="alternate"][hreflang="x-default"]', visible: false)
  end

  it 'should have alternate links to all locales' do
    render
    available_locales.each do |locale|
      expect(rendered).to have_selector("link[rel=\"alternate\"][hreflang=\"#{locale}\"]", visible: false)
    end
  end

  it 'should have JS vars' do
    I18n.locale = 'fr'

    render
    expect(rendered).to have_selector('script', text: 'var i18nDefaultLocale = "en";', visible: false)
    expect(rendered).to have_selector('script', text: 'var i18nLocale = "fr";', visible: false)

    I18n.locale = I18n.default_locale
  end

  it 'should have language menu links to all locales' do
    class AvailableLocales
      include I18nHelper
    end
    language_map = AvailableLocales.new.language_map

    render
    available_locales.each do |locale|
      label = I18n.t("global.language-#{language_map[locale]}", locale: locale)
      expect(rendered).to have_selector('#settings-menu a', text: label)
    end
  end
end
