module Collections
  class Show < ApplicationView
    def head_meta
      @mustache[:head_meta] ||= begin
        [
          { meta_name: 'description', content: truncate(strip_tags(@landing_page.body), length: 350, separator: ' ') }
        ] + super
      end
    end

    def page_title
      @mustache[:page_title] ||= begin
        (@landing_page.title || @collection.key) + ' Collection - Alpha'
      end
    end

    def body_class
      'channel_landing'
    end

    def globalnav_options
      @mustache[:globalnav_options] ||= begin
        {
          search: false,
          myeuropeana: true
        }
      end
    end

    def content
      @mustache[:content] ||= begin
        {
          channel_info: {
            name: @landing_page.title,
            description: @landing_page.body,
            stats: {
              items: stylised_collection_stats
            },
            recent: @recent_additions.blank? ? nil : {
              title: t('site.channels.labels.recent'),
              items: stylised_recent_additions(@recent_additions, max: 3)
            },
            credits: @landing_page.credits.blank? ? {} : {
              title: t('site.channels.labels.credits'),
              items: @landing_page.credits.to_a
            }
          },
          hero_config: hero_config(@landing_page.hero_image),
          channel_entry: @landing_page.browse_entries.blank? ? nil : {
            items: browse_entry_items(@landing_page.browse_entries)
          },
          promoted: @landing_page.promotions.blank? ? nil : {
            items: promoted_items(@landing_page.promotions)
          },
          news: blog_news_items.blank? ? nil : {
            items: blog_news_items,
            blogurl: 'http://blog.europeana.eu/tag/#' + @collection.key
          },
          social: @landing_page.social_media.blank? ? nil : social_media_links
        }.reverse_merge(helpers.content)
      end
    end

    private

    def detect_link_in_array(links, domain)
      matcher = %r(://([^/]*.)?#{domain}/)
      links.detect { |l| l.url =~ matcher }
    end

    # @todo move into {Link::SocialMedia} as {#twitter?} etc
    def social_media_links
      {
        twitter: detect_link_in_array(@landing_page.social_media, 'twitter.com'),
        facebook: detect_link_in_array(@landing_page.social_media, 'facebook.com'),
        soundcloud: detect_link_in_array(@landing_page.social_media, 'soundcloud.com'),
        pinterest: detect_link_in_array(@landing_page.social_media, 'pinterest.com'),
        googleplus: detect_link_in_array(@landing_page.social_media, 'plus.google.com')
      }
    end

    def blog_news_items
      @blog_news_items ||= begin
        key = @collection.key.underscore.to_sym
        url = Cache::FeedJob::URLS[:blog][key]
        news_items(feed_entries(url))
      end
    end

    def stylised_collection_stats
      return @stylised_collection_stats unless @stylised_collection_stats.blank?
      return nil unless @collection_stats.present?
      @stylised_collection_stats = @collection_stats.deep_dup.tap do |collection_stats|
        collection_stats.each do |stats|
          stats[:count] = number_with_delimiter(stats[:count])
        end
      end
    end
  end
end
