module MustacheHelper
  def form_search
    {
      action: search_action_path(only_path: true)
    }
  end

  def head_links
    [
      # { rel: 'shortcut icon', type: 'image/x-icon', href: asset_path('favicon.ico') },
      { rel: 'stylesheet', href: styleguide_url('/css/search/screen.css'), media: 'all' }
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

  def version
    { is_alpha: content[:phase_feedback].present? }
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
      data_main: styleguide_url('/js/dist/main/main') }]
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

  def channel_data
    name = nil
    if !(params[:controller] == 'portal' && params[:action] == 'show')
      name = params[:id] ? params[:id] : nil
    end
    if !name.nil?
      {
        name: name,
        label: t("site.channels.#{name}.title"),
        url: name ? channel_url(name) : nil
      }
    end
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
                items: ['art-history', 'music'].map do |channel|
                  {
                    url: channel_url(channel),
                    text: t("site.channels.#{channel}.title"),
                    is_current: params[:id] == channel
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
      menu_id: 'settings-menu',
      style_modifier: 'caret-right',
      tabindex: 6,
      items: [
        {
          url: '#',
          text: 'Settings',
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
              #   text: 'Channel Admin',
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

  def content
    banner = Banner.find_by_key('phase-feedback')
    banner = Banner.new unless current_user.can? :show, banner
    {
      phase_feedback: banner.new_record? ? nil : {
        title: banner.title,
        text: banner.body,
        cta_url: banner.link.url,
        cta_text: banner.link.text
      }
    }
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

  def hero_config(hero_image)
    hero_license = hero_image.license.blank? ? {} : { license_template_var_name(hero_image.license) => true }
    {
      hero_image: hero_image.file.url,
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
  # @param [ActiveRecord::Associations::CollectionProxy<BrowseEntry>
  def channel_entry_items(browse_entries)
    browse_entries.map do |entry|
      cat_flag = entry.settings_category.blank? ? {} : { :"is_#{entry.settings_category}" => true }
      {
        title: entry.title,
        url: browse_entry_url(entry),
        image: entry.file.nil? ? nil : entry.file.url,
        image_alt: nil
      }.merge(cat_flag)
    end
  end

  def license_template_var_name(license)
    'license_' + license.tr('-', '_')
  end
end
