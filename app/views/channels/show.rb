module Channels
  class Show < ApplicationView
    def page_title
      t('site.channels.' + @channel.key + '.title') + ' Channel - Alpha'
    end

    def body_class
      'channel_landing'
    end

    def globalnav_options
      {
        search: false,
        myeuropeana: true
      }
    end

    def content
      {
        channel_info: {
          name: t('site.channels.' + @channel.key + '.title'),
          description: t('site.channels.' + @channel.key + '.description'),
          stats: {
            items: stylised_channel_stats
          },
          recent: stylised_recent_additions.blank? ? nil : {
            title: t('site.channels.labels.recent'),
            items: stylised_recent_additions
          },
          credits: @landing_page.credits.blank? ? {} : {
            title: t('site.channels.labels.credits'),
            items: @landing_page.credits.to_a
          }
        },
        hero_config: hero_config(@landing_page.hero_image),
        channel_entry: {
          items: stylised_channel_entry
        },
        promoted: @landing_page.promotions.blank? ? nil : {
          items: promoted_items(@landing_page.promotions)
        },
        news: blog_news_items.blank? ? nil : {
          items: blog_news_items,
          blogurl: 'http://blog.europeana.eu/tag/#' + @channel.key
        },
        social: social_media_links
      }
    end

    private

    def detect_link_in_array(links, matcher)
      links.detect { |l| l.url =~ matcher }
    end

    # @todo move into {Link::SocialMedia} as {#twitter?} etc
    def social_media_links
      {
        twitter: detect_link_in_array(@landing_page.social_media, %r(://([^/]*.)?twitter.com/)),
        facebook: detect_link_in_array(@landing_page.social_media, %r(://([^/]*.)?facebook.com/)),
        soundcloud: detect_link_in_array(@landing_page.social_media, %r(://([^/]*.)?soundcloud.com/))
      }
    end

    def channel_content
      @channel_content ||= {} #@channel.config[:content] || {}
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
