module Templates
  module Search
    class ChannelsLanding < ApplicationView
      def body_class
        'channel_landing'
      end

      def globalnav_options
        {
          search: false,
          myeuropeana: true
        }
      end

      def page_config
        {
          newsletter: true
        }
      end

      def content
        {
          channel_info: {
            name: t('site.channels.' + @channel.id.to_s + '.title'),
            description: t('site.channels.' + @channel.id.to_s + '.description'),
            stats: {
              items: stylised_channel_stats
            },
            recent: stylised_recent_additions.blank? ? nil : {
              title: t('site.channels.labels.recent'),
              items: stylised_recent_additions
            },
            credits: {
              title: t('site.channels.labels.credits'),
              items: channel_content[:credits]
            }
          },
          hero_config: channel_content[:hero_config],
          channel_entry: {
            items: stylised_channel_entry
          },
          promoted: {
            items: channel_content[:promoted]
          },
          news: blog_news_items.blank? ? nil : {
            items: blog_news_items,
            blogurl: 'http://blog.europeana.eu/tag/#' + @channel.id
          },
          social: channel_content[:social]
        }
      end

      def navigation
        @channel.id == 'music' ? navigation_music : navigation_art
      end

      def navigation_common
        {
          global: {
            options: {
              search_active: false,
              settings_active: true
            },
            logo: {
              url: root_url,
              text: 'Europeana Search'
            },
            primary_nav: {
              items: [
                {
                  url: root_url,
                  text: 'Home',
                  is_current: false
                },
                {
                  url: root_url + 'channels/art',
                  text: 'Channels',
                  is_current: true,
                  submenu: {
                    items: [
                      {
                        url: root_url + 'channels/art',
                        text: 'Art History'
                      },
                      {
                        url: root_url + 'channels/music',
                        text: 'Music'
                      }
                    ]
                  }
                },
                {
                  url: 'http://exhibitions.europeana.eu/',
                  text: 'Exhibitions'
                },
                {
                  url: 'http://blog.europeana.eu/',
                  text: 'Blog'
                },
                {
                  url: root_url + 'myeuropeana#login',
                  text: 'My Europeana'
                }
              ]
            }  # end prim nav
          },
          footer: {
            linklist1: {
              title: t('global.more-info'),
              items: [
                {
                  text: t('site.footer.menu.new-collections'),
                  url: '#'
                },
                {
                  text: t('site.footer.menu.data-providers'),
                  url: '#'
                },
                {
                  text: t('site.footer.menu.become-a-provider'),
                  url: '#'
                }
              ]
            },
            linklist2: {
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
              googleplus: true,
              github: false
            }
          }
        }
      end

      def navigation_art
        {
          global: navigation_common[:global],
          footer: navigation_common[:footer]
        }
      end

      def navigation_music
        {
          global: navigation_common[:global],
          footer: navigation_common[:footer]
        }
      end

      private

      def channel_content
        @channel_content ||= @channel.config[:content] || {}
      end

      def blog_news_items
        @blog_news_items ||= news_items(@blog_items)
      end

      def stylised_channel_entry
        return @stylised_channel_entry unless @stylised_channel_entry.blank?
        return nil unless @channel_entry.present?
        @stylised_channel_entry = @channel_entry.deep_dup.tap do |channel_entry|
          channel_entry.each do |entry|
            entry[:count] = number_with_delimiter(entry[:count])
            entry[:image_alt] ||= nil
          end
        end
      end

      def stylised_channel_stats
        return @stylised_channel_stats unless @stylised_channel_stats.blank?
        return nil unless @channel_stats.present?
        @stylised_channel_stats = @channel_stats.deep_dup.tap do |channel_stats|
          channel_stats.each do |stats|
            stats[:count] = number_with_delimiter(stats[:count])
          end
        end
      end

      def stylised_recent_additions
        return @stylised_recent_additions unless @stylised_recent_additions.blank?
        return nil unless @recent_additions.present?
        @stylised_recent_additions = @recent_additions.deep_dup.tap do |recent_additions|
          recent_additions.each do |addition|
            addition[:number] = number_with_delimiter(addition[:number]) + ' ' + t('site.channels.data-types.count')
          end
        end
      end
    end
  end
end
