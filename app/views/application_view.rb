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
  include FeedbackableView
  include LocalisableView
  include NavigableView

  def head_links
    links = [
      { rel: 'search', type: 'application/opensearchdescription+xml',
        href: Rails.application.config.x.europeana_opensearch_host + '/opensearch.xml',
        title: 'Europeana Search' },
      { rel: 'alternate', href: current_url_without_locale, hreflang: 'x-default' }
    ] + alternate_language_links

    { items: links }
  end

  def fb_campaigns_on
    true
  end

  def version
    { is_alpha: true }
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
end
