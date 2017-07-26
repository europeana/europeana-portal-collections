##
# A custom class for this project's Mustache templates
#
# Each page-specific view class should sub-class this.
#
# Public methods added to this class will be available to all Mustache
# templates.
class ApplicationView < Europeana::Styleguide::View
  include AssettedView
  include BanneredView
  include CacheableView
  include Europeana::FeedbackButton::FeedbackableView
  include LocalisableView
  include NavigableView

  def page_title
    [page_content_heading, site_title].join(' - ')
  end

  # Override in view subclasses for use in #page_title
  def page_content_heading
    ''
  end

  def js_vars
    [
      { name: 'enableCSRFWithoutSSL', value: config.x.enable[:csrf_without_ssl] },
      { name: 'googleAnalyticsKey', value: config.x.google.analytics_key },
      { name: 'googleOptimizeContainerID', value: config.x.google.optimize_container_id },
      { name: 'i18nLocale', value: I18n.locale },
      { name: 'i18nDefaultLocale', value: I18n.default_locale },
      { name: 'ugcEnabledCollections', value: ugc_enabled_collections_js_var_value, unquoted: true }
    ] + super
  end

  def head_meta
    no_csrf = super.reject { |meta| %w(csrf-param csrf-token).include?(meta[:meta_name]) }
    return no_csrf unless config.x.google.site_verification.present?
    [
      {
        meta_name: 'google-site-verification', content: config.x.google.site_verification
      }
    ] + no_csrf
  end

  def head_links
    links = [
      { rel: 'search', type: 'application/opensearchdescription+xml',
        href: config.x.europeana[:opensearch_host] + '/opensearch.xml',
        title: 'Europeana Search' },
      { rel: 'alternate', href: current_url_without_locale, hreflang: 'x-default' }
    ] + alternate_language_links

    { items: links }
  end

  def fb_campaigns_on
    true
  end

  def page_config
    {
      newsletter: true
    }
  end

  def newsletter
    {
      form: {
        action: 'https://europeana.us3.list-manage.com/subscribe/post?u=ad318b7566f97eccc895e014e&amp;id=1d4f51a117',
        language_op: true
      }
    }
  end

  def content
    mustache[:content] ||= begin
      {
        banner: banner_content
      }
    end
  end

  def cookie_disclaimer
    {
      more_link: controller.static_page_path('rights/privacy', format: 'html')
    }
  end

  protected

  def ugc_enabled_collections_js_var_value
    '[' + Collection.ugc_acceptor_keys.map { |key| "'#{key}'" }.join(',') + ']'
  end

  def site_title
    'Europeana Collections'
  end

  def alternate_language_links
    language_map.keys.map do |locale|
      { rel: 'alternate', hreflang: locale, href: current_url_for_locale(locale) }
    end
  end

  def devise_user
    current_user || User.new(guest: true)
  end

  def mustache
    @mustache ||= {}
  end

  def config
    Rails.application.config
  end
end
