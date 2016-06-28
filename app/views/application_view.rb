##
# A custom class for this project's Mustache templates
#
# Each page-specific view class should sub-class this.
#
# Public methods added to this class will be available to all Mustache
# templates.
class ApplicationView < Europeana::Styleguide::View
  def form_search
    {
      action: search_action_path(only_path: true)
    }
  end

  def css_files
    [
      {
        path: styleguide_url('/css/search/screen.css'),
        media: 'all'
      }
    ]
  end

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

  def page_locale
    session[:locale]
  end

  # model for the search form
  def input_search
    {
      title: t('global.search-area.search-button-image-alt'),
      input_name: params[:q].blank? ? 'q' : 'qf[]',
      has_original: !params[:q].blank?,
      input_original: {
        value:  params[:q].blank? ? nil : params[:q],
        remove: search_action_url(remove_q_param(params))
      },
      input_values: input_search_values(*search_param_keys),
      placeholder: t('site.search.placeholder.text')
    }
  end

  def version
    { is_alpha: true }
  end

  def js_vars
    page_name = (params[:controller] || '') + '/' + (params[:action] || '')
    [
      {
        name: 'pageName', value: page_name
      }
    ]
  end

  def js_files
    [
      {
        path: styleguide_url('/js/dist/require.js'),
        data_main: styleguide_url('/js/dist/main/main-collections')
      }
    ]
  end

  def total_item_count
    @europeana_item_count ? number_with_delimiter(@europeana_item_count) : nil
  end

  def collections_nav_links
    available_collections.map do |c|
      {
        url: collection_path(c),
        text: c
      }
    end
  end

  def page_config
    {
      newsletter: true
    }
  end

  def newsletter
    {
      form: {
        action: 'http://europeana.us3.list-manage.com/subscribe/post?u=ad318b7566f97eccc895e014e&amp;id=1d4f51a117',
        language_op: true
      }
    }
  end

  def collection_data
    mustache[:collection_data] ||= begin
      if within_collection?
        collection = current_collection
        {
          name: collection.key,
          label: collection.landing_page.title,
          url: collection_url(collection)
        }
      end
    end
  end
  alias_method :channel_data, :collection_data

  def navigation
    mustache[:navigation] ||= begin
      {
        global: {
          options: {
            search_active: false,
            settings_active: true
          },
          logo: {
            url: root_path,
            text: 'Europeana ' + t('global.search-collections')
          },
          primary_nav: {
            menu_id: 'main-menu',
            items: [
              {
                url: root_path,
                text: t('global.navigation.home'),
                is_current: controller.controller_name == 'home'
              },
              {
                text: t('global.navigation.collections'),
                is_current: controller.controller_name == 'collections',
                submenu: {
                  items: navigation_global_primary_nav_collections_submenu_items
                }
              },
              {
                text: t('global.navigation.browse'),
                is_current: controller.controller_name == 'browse',
                submenu: {
                  items: navigation_global_primary_nav_browse_submenu_items
                }
              },
              {
                url: 'http://exhibitions.europeana.eu/',
                text: t('global.navigation.exhibitions'),
                submenu: {
                  items: navigation_global_primary_nav_exhibitions_submenu_items
                }
              },
              {
                url: 'http://blog.europeana.eu/',
                text: t('global.navigation.blog'),
                submenu: {
                  items: navigation_global_primary_nav_blog_submenu_items
                }
              }
            ]
          }
        },
        home_url: root_url,
        footer: {
          linklist1: {
            title: t('global.more-info'),
            items: navigation_footer_linklist1_items
          },
          linklist2: {
            title: t('global.help'),
            items: navigation_footer_linklist2_items
          },
          social: {
            facebook: true,
            pinterest: true,
            twitter: true,
            googleplus: true
          }
        }
      }
    end
  end

  def utility_nav
    mustache[:utility_nav] ||= begin
      {
        menu_id: 'settings-menu',
        style_modifier: 'caret-right',
        tabindex: 6,
        items: [
          {
            url: '#',
            text: t('site.settings.language.label'),
            icon: 'settings',
            submenu: {
              items: utility_nav_items_submenu_items
            }
          }
        ]
      }
    end
  end

  def content
    mustache[:content] ||= begin
      {
        banner: banner_content
      }
    end
  end

  def collection_filter_options
    ops = displayable_collections.map do |collection|
      {
        value: collection.key,
        label: collection.landing_page.title,
        selected: params['theme'] == collection.key
      }
    end
    {
      options: ops.unshift({
        value: '*',
        label: t('global.actions.filter-all')
      })
    }
  end

  def cached_body
    lambda do |text|
      if cache_body?
        Rails.cache.fetch(cache_key, expires_in: 24.hours) { render(text) }
      else
        render(text)
      end
    end
  end

  protected

  def site_title
    'Europeana Collections'
  end

  private

  def alternate_language_links
    language_map.keys.map do |locale|
      { rel: 'alternate', hreflang: locale, href: current_url_for_locale(locale) }
    end
  end

  def current_url_for_locale(locale)
    url_for(params.merge(locale: locale, only_path: false))
  end

  def current_url_without_locale
    url_for(params.merge(only_path: false)).sub("/#{I18n.locale}", '')
  end

  def navigation_global_primary_nav_collections_submenu_items
    displayable_collections.map do |collection|
      link_item(collection.title, collection_path(collection),
                is_current: current_page?(collection_path(collection)))
    end
  end

  def navigation_global_primary_nav_browse_submenu_items
    [
      link_item(t('global.navigation.browse_newcontent'), browse_newcontent_path,
                is_current: current_page?(browse_newcontent_path)),
      link_item(t('global.navigation.browse_colours'), browse_colours_path,
                is_current: current_page?(browse_colours_path)),
      link_item(t('global.navigation.browse_sources'), browse_sources_path,
                is_current: current_page?(browse_sources_path)),
      link_item(t('global.navigation.concepts'), browse_topics_path,
                is_current: current_page?(browse_topics_path)),
      link_item(t('global.navigation.agents'), browse_people_path,
                is_current: current_page?(browse_people_path))
    ]
  end

  def navigation_global_primary_nav_exhibitions_submenu_items
    feed_items = feed_entry_nav_items(Cache::FeedJob::URLS[:exhibitions][exhibitions_feed_key], 6)
    feed_items << link_item(t('global.navigation.all_exhibitions'), 'http://exhibitions.europeana.eu/',
                            is_morelink: true)
  end

  def navigation_global_primary_nav_blog_submenu_items
    feed_items = feed_entry_nav_items(Cache::FeedJob::URLS[:blog][:all], 6)
    feed_items << link_item(t('global.navigation.all_blog_posts'), 'http://blog.europeana.eu/',
                            is_morelink: true)
  end

  def utility_nav_items_submenu_items
    language_map.map do |locale, i18n|
      label = t("global.language-#{i18n}", locale: locale)
      link_item(label, current_url_for_locale(locale),
                is_current: (locale.to_s == I18n.locale.to_s))
    end
  end

  def navigation_footer_linklist1_items
    [
      link_item(t('site.footer.menu.about'), static_page_path('about', format: 'html')),
      link_item(t('site.footer.menu.roadmap'), static_page_path('roadmap', format: 'html')),
      link_item(t('site.footer.menu.data-providers'), static_page_path('browse/sources', format: 'html')),
      link_item(t('site.footer.menu.become-a-provider'), 'http://pro.europeana.eu/share-your-data/'),
      link_item(t('site.footer.menu.contact-us'), static_page_path('contact', format: 'html')),
    ]
  end

  def navigation_footer_linklist2_items
    [
      link_item(t('site.footer.menu.search-tips'), static_page_path('help', format: 'html')),
      link_item(t('global.terms-and-policies'), static_page_path('rights', format: 'html'))
    ]
  end

  def link_item(text, url, options = {})
    { text: text, url: url }.merge(options)
  end

  def page_banner(id = nil)
    banner = id.nil? ? Banner.find_by_default(true) : Banner.find(id)
    return nil unless devise_user.can?(:show, banner)
    banner
  end

  def devise_user
    current_user || User.new(guest: true)
  end

  def banner_content(id = nil)
    banner = page_banner(id)
    return nil if banner.nil?

    {
      title: banner.title,
      text: banner.body,
      cta_url: banner.link.present? ? banner.link.url : nil,
      cta_text: banner.link.present? ? banner.link.text : nil
    }
  end

  def mustache
    @mustache ||= {}
  end

  def feed_entry_nav_items(url, max)
    feed_entries(url)[0..(max - 1)].map do |item|
      {
        url: CGI.unescapeHTML(item.url),
        text: CGI.unescapeHTML(item.title)
      }
    end
  end

  # @param keys [Symbol] keys of params to gather template input field data for
  # @return [Array<Hash>]
  def input_search_values(*keys)
    return [] if keys.blank?
    keys.map do |k|
      [params[k]].flatten.compact.reject(&:blank?).map do |v|
        {
          name: params[k].is_a?(Array) ? "#{k}[]" : k.to_s,
          value: input_search_param_value(k, v),
          remove: search_action_url(remove_search_param(k, v, params))
        }
      end
    end.flatten.compact
  end

  ##
  # Returns text to display on-screen for an active search param
  #
  # @param key [Symbol] parameter key
  # @param value value of the parameter
  # @return [String] text to display
  def input_search_param_value(key, value)
    case key
    when :mlt
      response, doc = controller.fetch(value)
      item = render_index_field_value(doc, ['dcTitleLangAware', 'title'])
      t('site.search.similar.prefix', mlt_item: item)
    else
      value.to_s
    end
  end

  ##
  # Keys of parameters to preserve across searches as hidden input fields
  #
  # @return [Array<Symbol>]
  def search_param_keys
    [:qf, :mlt]
  end

  def news_items(items)
    return nil if items.blank?
    items[0..2].map do |item|
      {
        image_root: nil,
        headline: {
          medium: CGI.unescapeHTML(item.title)
        },
        url: CGI.unescapeHTML(item.url),
        img: {
          src: feed_entry_img_src(item),
          alt: nil
        },
        excerpt: {
          short: CGI.unescapeHTML(item.summary)
        }
      }
    end
  end

  def hero_config(hero_image)
    return nil unless hero_image.present?
    hero_license = hero_image.license.blank? ? {} : { license_template_var_name(hero_image.license) => true }
    {
      hero_image: hero_image.file.present? ? hero_image.file.url : nil,
      attribution_title: hero_image.settings_attribution_title,
      attribution_creator: hero_image.settings_attribution_creator,
      attribution_institution: hero_image.settings_attribution_institution,
      attribution_url: hero_image.settings_attribution_url,
      attribution_text: hero_image.settings_attribution_text,
      brand_opacity: "brand-opacity#{hero_image.settings_brand_opacity}",
      brand_position: "brand-#{hero_image.settings_brand_position}",
      brand_colour: "brand-colour-#{hero_image.settings_brand_colour}"
    }.merge(hero_license)
  end

  def promoted_items(promotions)
    promotions.map do |promo|
      cat_flag = promo.settings_category.blank? ? {} : { :"is_#{promo.settings_category}" => true }
      {
        url: promo.url,
        title: promo.text,
        custom_class: promo.settings_class,
        wide: promo.settings_wide == '1',
        bg_image: promo.file.nil? ? nil : promo.file.url
      }.merge(cat_flag)
    end
  end

  ##
  # @param page [Page]
  def browse_entry_items(browse_entries, page = nil)
    browse_entries.map do |entry|
      cat_flag = entry.settings_category.blank? ? {} : { :"is_#{entry.settings_category}" => true }
      {
        title: entry.title,
        url: browse_entry_url(entry, page),
        image: entry.file.nil? ? nil : entry.file.url,
        image_alt: nil
      }.merge(cat_flag)
    end
  end

  def license_template_var_name(license)
    'license_' + license.tr('-', '_')
  end

  def exhibitions_feed_key
    Cache::FeedJob::URLS[:exhibitions].key?(I18n.locale) ? I18n.locale : :en
  end

  def blog_news_items(collection)
    mustache[:blog_news_items] ||= {}
    mustache[:blog_news_items][collection.key] ||= begin
      key = collection.key.underscore.to_sym
      url = Cache::FeedJob::URLS[:blog][key]
      news_items(feed_entries(url))
    end
  end

  def cache_version
    @cache_version ||= begin
      v = Rails.application.config.assets.version.dup
      unless Rails.application.config.x.cache_version.blank?
        v << ('-' + Rails.application.config.x.cache_version.dup)
      end
      v
    end
  end

  def cache_key
    keys = ['views', cache_version, I18n.locale.to_s, devise_user.role || 'guest', body_cache_key]
    keys.compact.join('/')
  end

  # Implement this method in sub-classes to enable body caching
  def body_cache_key
    fail NotImplementedError
  end

  def cache_body?
    !request.format.json? && !ENV['DISABLE_VIEW_CACHING']
  end
end
