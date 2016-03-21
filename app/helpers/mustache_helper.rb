module MustacheHelper
  def form_search
    {
      action: search_action_path(only_path: true)
    }
  end

  def head_links
    links = [
      # { rel: 'shortcut icon', type: 'image/x-icon', href: asset_path('favicon.ico') },
      { rel: 'stylesheet', href: styleguide_url('/css/search/screen.css'), media: 'all', css: 'true' },
      { rel: 'search', type: 'application/opensearchdescription+xml',
        href: Rails.application.config.x.europeana_opensearch_host + '/opensearch.xml',
        title: 'Europeana Search' }
    ]
    if params[:controller] == 'home' && params[:action] == 'index'
      links << { rel: 'canonical', href: root_url }
    end
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
    { is_alpha: content[:banner].present? }
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
    [{ path: styleguide_url('/js/dist/require.js'),
      data_main: styleguide_url('/js/dist/main/main-collections') }]
  end

  # def menus
  #   {
  #     actions: {
  #       button_title: 'Actions',
  #       menu_id: 'dropdown-result-actions',
  #       menu_title: 'Save to:',
  #       items: [
  #         {
  #           url: 'http://europeana.eu',
  #           text: 'First Item'
  #         },
  #         {
  #           url: 'http://europeana.eu',
  #           text: 'Another Label'
  #         },
  #         {
  #           url: 'http://europeana.eu',
  #           text: 'Label here'
  #         },
  #         {
  #           url: 'http://europeana.eu',
  #           text: 'Fourth Item'
  #         },
  #         {
  #           divider: true
  #         },
  #         {
  #           url: 'http://europeana.eu',
  #           text: 'Another Label',
  #           calltoaction: true
  #         },
  #         {
  #           divider: true
  #         },
  #         {
  #           url: 'http://europeana.eu',
  #           text: 'Another Label',
  #           calltoaction: true
  #         }
  #       ]
  #     },
  #     sort: {
  #       button_title: 'Relevance',
  #       menu_id: 'dropdown-result-sort',
  #       menu_title: 'Sort by:',
  #       items: [
  #         {
  #           text: 'Date',
  #           url: 'http://europeana.eu'
  #         },
  #         {
  #           text: 'Alphabetical',
  #           url: 'http://europeana.eu'
  #         },
  #         {
  #           text: 'Relevance',
  #           url: 'http://europeana.eu'
  #         },
  #         {
  #           divider: true
  #         },
  #         {
  #           url: 'http://europeana.eu',
  #           text: 'Another Label',
  #           calltoaction: true
  #         },
  #         {
  #           divider: true
  #         },
  #         {
  #           text: 'Advanced Search',
  #           url: 'http://europeana.eu',
  #           calltoaction: true
  #         }
  #       ]
  #     }
  #   }
  # end

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
      name = nil
      if !(params[:controller] == 'portal' && params[:action] == 'show')
        name = params[:id] ? params[:id] : nil
      end
      if !name.nil?
        {
          name: name,
          label: t("site.collections.#{name}.title"),
          url: name ? collection_url(name) : nil
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
                  items: displayable_collections.map do |collection|
                    {
                      url: collection_path(collection),
                      text: collection.landing_page.title,
                      is_current: current_page?(collection_path(collection))
                    }
                  end
                }
              },
              {
                text: t('global.navigation.browse'),
                is_current: controller.controller_name == 'browse',
                submenu: {
                  items: [
                    {
                      url: browse_newcontent_path,
                      text: t('global.navigation.browse_newcontent'),
                      is_current: current_page?(browse_newcontent_path)
                    },
                    {
                      url: browse_colours_path,
                      text: t('global.navigation.browse_colours'),
                      is_current: current_page?(browse_colours_path)
                    },
                    {
                      url: browse_sources_path,
                      text: t('global.navigation.browse_sources'),
                      is_current: current_page?(browse_sources_path)
                    },
                    {
                      url: browse_concepts_path,
                      text: t('global.navigation.concepts'),
                      is_current: current_page?(browse_concepts_path)
                    },
                    {
                      url: browse_agents_path,
                      text: t('global.navigation.agents'),
                      is_current: current_page?(browse_agents_path)
                    }
                  ]
                }
              },
              {
                url: 'http://exhibitions.europeana.eu/',
                text: t('global.navigation.exhibitions'),
                submenu: {
                  items: feed_entry_nav_items(Cache::FeedJob::URLS[:exhibitions][:all], 6) + [
                    {
                      url: 'http://exhibitions.europeana.eu/',
                      text: t('global.navigation.all_exhibitions'),
                      is_morelink: true
                    }
                  ]
                }
              },
              {
                url: 'http://blog.europeana.eu/',
                text: t('global.navigation.blog'),
                submenu: {
                  items: feed_entry_nav_items(Cache::FeedJob::URLS[:blog][:all], 6) + [
                    {
                      url: 'http://blog.europeana.eu/',
                      text: t('global.navigation.all_blog_posts'),
                      is_morelink: true
                    }
                  ]
                }
              }
            ]
          }  # end prim nav
        },
        home_url: root_url,
        footer: {
          linklist1: {
            title: t('global.more-info'),
            # Use less elegant way to get footer links
            #
            # items: Page.primary.map do |page|
            #   {
            #     text: t(page.slug, scope: 'site.footer.menu'),
            #     url: static_page_path(page, format: 'html')
            #   }
            # end
            items: [
              {
                text: t('site.footer.menu.about'),
                url: static_page_path('about', format: 'html')
              },
              {
                text: t('site.footer.menu.data-providers'),
                url: static_page_path('browse/sources', format: 'html')
              },
              {
                text: t('site.footer.menu.become-a-provider'),
                url: 'http://pro.europeana.eu/share-your-data/'
              }
            ]
          },
          linklist2: {
            title: t('global.help'),
            items: [
              {
                text: t('site.footer.menu.search-tips'),
                url: static_page_path('help', format: 'html')
              },
              # {
              #   text: t('site.footer.menu.using-myeuropeana'),
              #   url: '#'
              # },
              {
                text: t('global.terms-and-policies'),
                url: static_page_path('rights', format: 'html')
              }
            ]
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
            text: t('global.settings'),
            icon: 'settings',
            submenu: {
              items: [
                {
                  text: t('global.settings'),
                  subtitle: true,
                  url: false
                },
                {
                  text: t('site.settings.language.label'),
                  url: '/portal/settings/language',
                  is_current: controller.controller_name == 'settings'
                },
                # {
                #   text: 'My Profile',
                #   url: 'url to profile page'
                # },
                # {
                #   text: 'Advanced',
                #   url: 'url to settings page'
                # },
                # {
                #   is_divider: true
                # },
                # {
                #   text: 'Admin',
                #   subtitle: true,
                #   url: false
                # },
                # {
                #   text: 'Collection Admin',
                #   url: 'url to admin page'
                # },
                # {
                #   is_divider: true
                # },
                # {
                #   text: 'Account',
                #   subtitle: true,
                #   url: false
                # },
                # {
                #   text: 'Log Out',
                #   url: 'url to login page'
                # }
              ]
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

  private

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
      [params[k]].flatten.compact.map do |v|
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
          src: news_item_img_src(item),
          alt: nil
        },
        excerpt: {
          short: CGI.unescapeHTML(item.summary)
        }
      }
    end
  end

  def news_item_img_src(item)
    return nil unless item.content.present?
    img_tag = item.content.match(/<img [^>]*>/i)[0]
    return nil unless img_tag.present?
    url = img_tag.match(/src="(https?:\/\/[^"]*)"/i)[1]
    mo = MediaObject.find_by_source_url_hash(MediaObject.hash_source_url(url))
    mo.nil? ? nil : media_object_url(mo, :medium)
  end

  def hero_config(hero_image)
    return nil unless hero_image.present?
    hero_license = hero_image.license.blank? ? {} : { license_template_var_name(hero_image.license) => true }
    {
      hero_image: hero_image.file.present? ? media_object_url(hero_image.media_object) : nil,
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

  def media_object_url(media_object, size = nil)
    cache_key = "media_object:url:#{media_object.id}-"
    cache_key << "-#{size}" unless size.nil?
    cache_key << "-#{media_object.updated_at.to_i}"
    Rails.cache.fetch(cache_key) do
      media_object.file.url(size)
    end
  end

  def promoted_items(promotions)
    promotions.map do |promo|
      cat_flag = promo.settings_category.blank? ? {} : { :"is_#{promo.settings_category}" => true }
      {
        url: promo.url,
        title: promo.text,
        custom_class: promo.settings_class,
        wide: promo.settings_wide == '1',
        bg_image: promo.file.nil? ? nil : media_object_url(promo.media_object)
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
        image: entry.file.nil? ? nil : media_object_url(entry.media_object),
        image_alt: nil
      }.merge(cat_flag)
    end
  end

  def license_template_var_name(license)
    'license_' + license.tr('-', '_')
  end
end
