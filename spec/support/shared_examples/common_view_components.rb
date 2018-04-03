RSpec.shared_examples 'common view components', :common_view_components do
  let(:available_locales) do
    I18n.available_locales
  end

  it 'should have site name in <title>' do
    site_name = I18n.t('site.name')
    render
    expect(rendered).to have_selector('title', text: /#{site_name}/, visible: false)
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

  describe 'JS vars' do
    it 'should indicate I18n locales' do
      I18n.locale = 'fr'

      render
      expect(rendered).to have_selector('script', text: 'var i18nDefaultLocale = "en";', visible: false)
      expect(rendered).to have_selector('script', text: 'var i18nLocale = "fr";', visible: false)

      I18n.locale = I18n.default_locale
    end

    describe 'googleAnalyticsLinkedDomains' do
      before do
        Rails.application.config.x.google.analytics_linked_domains = google_analytics_linked_domains
      end

      context 'when none are configured' do
        let(:google_analytics_linked_domains) { [] }
        it 'is a blank JS array' do
          render
          expect(rendered).to have_selector('script', text: 'var googleAnalyticsLinkedDomains = [];', visible: false)
        end
      end

      context 'when some are configured' do
        let(:google_analytics_linked_domains) { %w(site1.example.com site2.example.com) }
        it 'is a JS array including them' do
          render
          expect(rendered).to have_selector('script', text: "var googleAnalyticsLinkedDomains = ['site1.example.com','site2.example.com'];", visible: false)
        end
      end
    end
  end

  it 'should have language menu links to all locales' do
    render
    available_locales.each do |locale|
      label = I18n.t(locale, scope: 'global.languages', locale: locale)
      expect(rendered).to have_selector('#settings-menu a', text: label)
    end
  end

  describe 'site notice' do
    context 'when enabled' do
      before(:each) do
        Rails.application.config.x.enable.site_notice = '1'
      end
      it 'is shown' do
        render
        expect(rendered).to have_selector('body > .site-notice .msg', text: I18n.t('site.notice.outage-expected'))
      end
    end

    context 'when not enabled' do
      before(:each) do
        Rails.application.config.x.enable.site_notice = nil
      end
      it 'is not shown' do
        render
        expect(rendered).not_to have_selector('.site-notice')
      end
    end
  end
end
