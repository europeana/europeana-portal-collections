##
# View methods for pages with navigation
module NavigableView
  extend ActiveSupport::Concern

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

  protected

  def exhibitions_feed_key
    Cache::FeedJob::URLS[:exhibitions].key?(I18n.locale) ? I18n.locale : :en
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

  def feed_entry_nav_items(url, max)
    feed_entries(url)[0..(max - 1)].map do |item|
      {
        url: CGI.unescapeHTML(item.url),
        text: CGI.unescapeHTML(item.title)
      }
    end
  end
end
