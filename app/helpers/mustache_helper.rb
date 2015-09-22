module MustacheHelper
  def head_meta
    [
      #{'name':'X-UA-Compatible',    content: 'IE=edge' },
      #{'name':'viewport',           content: 'width=device-width,initial-scale=1.0' },
      { meta_name: 'HandheldFriendly',   content: 'True' },
      { httpequiv: 'Content-Type',       content: 'text/html; charset=utf-8' },
      { meta_name: 'csrf-param',         content: 'authenticity_token' },
      { meta_name: 'csrf-token',         content: form_authenticity_token }
    ]
  end

  def form_search
    {
      action: search_action_path(only_path: true)
    }
  end

  def head_links
    [
      # { rel: 'shortcut icon', type: 'image/x-icon', href: asset_path('favicon.ico') },
      { rel: 'stylesheet', href: styleguide_path('/css/search/screen.css'), media: 'all' }
    ]
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

  def image_root
    styleguide_path('/images/')
  end

  def version
    { is_alpha: true }
  end

  def js_version
    Rails.application.config.x.js_version || ''
  end

  def js_variables
    'var js_path="' + styleguide_path('/js/dist/') + '"; ' +
    'var require = {"urlArgs": "' + js_version  + '"};'
  end

  def js_files
    js_entry_point = Rails.application.config.x.js_entrypoint || '/js/dist/'
    js_entry_point = js_entry_point.dup << '/' unless js_entry_point.end_with?('/')
    [{ path: styleguide_path(js_entry_point + 'require.js?cache=' + js_version),
       data_main: styleguide_path(js_entry_point + 'main/main'),
       js_version: js_version}]
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

  def channels_nav_links
    available_channels.collect do |c|
      {
        url: channel_path(c),
        text: c
      }
    end
  end

  def page_config
    {
      newsletter: false
    }
  end

  def navigation
    {
      global: {
        options: {
          search_active: false,
          settings_active: true
        },
        logo: {
          url: root_url,
          text: 'Europeana ' + t('global.search-collections')
        },
        primary_nav: {
          menu_id: 'main-menu',
          items: [
            {
              url: root_url,
              text: t('global.navigation.home'),
              is_current: controller.controller_name == 'home'
            },
            {
              text: t('global.navigation.channels'),
              is_current: controller.controller_name == 'channels',
              submenu: {
                items: ['music'].map do |channel|
                  {
                    url: channel_url(channel),
                    text: t("site.channels.#{channel}.title")
                  }
                end
              }
            },
            {
              url: 'http://exhibitions.europeana.eu/',
              text: t('global.navigation.exhibitions'),
              submenu: {
                items: feed_entry_nav_items(FeedCacheJob::URLS[:exhibitions][:all], 6) + [
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
                items: feed_entry_nav_items(FeedCacheJob::URLS[:blog][:all], 6) + [
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
      footer: {
        linklist1: {
          title: t('global.more-info'),
          items: [
            {
              text: t('site.footer.menu.about'),
              url: root_url + '/about.html'
            }
            # {
            #   text: t('site.footer.menu.new-collections'),
            #   url: '#'
            # },
            # {
            #   text: t('site.footer.menu.data-providers'),
            #   url: '#'
            # },
            # {
            #   text: t('site.footer.menu.become-a-provider'),
            #   url: '#'
            # }
          ]
        },
        xxx_linklist2: {
          title: t('global.help'),
          items: [
            {
              text: t('site.footer.menu.search-tips'),
              url: '#'
            },
            {
              text: t('site.footer.menu.using-myeuropeana'),
              url: '#'
            },
            {
              text: t('site.footer.menu.copyright'),
              url: '#'
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

  def utility_nav
    {
      menu_id: "settings-menu",
      style_modifier: "caret-right",
      tabindex: "6",
      items: [
        {
          url: "url to settings",
          text: "Settings",
          icon: "settings",
          submenu: {
            items: [
              {
                text: "Settings",
                subtitle: true,
                url: false
              },
              {
                text: "Language ",
                url: "/portal/settings/language",
                is_current: controller.controller_name == 'settings'
              },
              # {
              #   text: "My Profile",
              #   url: "url to profile page"
              # },
              # {
              #   text: "Advanced",
              #   url: "url to settings page"
              # },
              # {
              #   is_divider: true
              # },
              # {
              #   text: "Admin",
              #   subtitle: true,
              #   url: false
              # },
              # {
              #   text: "Channel Admin",
              #   url: "url to admin page"
              # },
              # {
              #   is_divider: true
              # },
              # {
              #   text: "Account",
              #   subtitle: true,
              #   url: false
              # },
              # {
              #   text: "Log Out",
              #   url: "url to login page"
              # }
            ]
          }
        }
      ]
    }
  end

  def content
    {
      phase_feedback: {
        title: t('site.alpha.feedback_banner.title'),
        text: t('site.alpha.feedback_banner.description'),
        cta_url: 'http://insights.hotjar.com/s?siteId=54631&surveyId=2939',
        cta_text: t('site.alpha.feedback_banner.link-text')
      }
    }
  end

  def settings
    {
      language: {
        title: "Language Settings",
        language_default: {
          title: "Default Language",
          group_id: "Available Languages",
          items: [
            {
              text:  t('global.language-english'),
              value: 'en'
            },
            {
              text: t('global.language-french'),
              value: 'fr'
            },
            {
              text: t('global.language-spanish'),
              value: 'es'
            }
          ]
        },
        language_itempages: {

          title: "Automatically translate item pages into...",
          label: "Auto translate items into",
          value: "autotranslateitem",
          item_id: "translate-item",
          is_checked: true,
          group_id: "Available Languages",
          items: [
            {
              text: "Nederlands",
              value: "nl"
            },
            {
              text: "عربي",
              value: "value"
            },
            {
              text: "Russian",
              value: "value"
            },
            {
              text: "Greek",
              value: "value"
            }
          ]
        }
      }
    }
  end

  def styleguide_path(asset = nil)
    Rails.application.config.x.europeana_styleguide_cdn + (asset.present? ? asset : '')
  end

  def styleguide_hero_config(hero_config)
    hero_config.deep_dup.tap do |hc|
      hc[:hero_image] = image_root + hc[:hero_image]
    end
  end

  private

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
    mo.nil? ? nil : mo.file.url(:medium)
  end
end
