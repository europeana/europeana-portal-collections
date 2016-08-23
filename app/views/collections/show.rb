module Collections
  class Show < ApplicationView
    include BrowsableView
    include BrowseEntryDisplayingView
    include HeroImageDisplayingView
    include NewsworthyView
    include PromotionLinkDisplayingView
    include SearchableView

    def head_meta
      mustache[:head_meta] ||= begin
        title = page_title
        description = truncate(strip_tags(@landing_page.body), length: 350, separator: ' ')
        description = description.strip! || description
        hero = hero_config(@landing_page.hero_image)
        head_meta = [
          { meta_name: 'description', content: description },
          { meta_property: 'fb:appid', content: '185778248173748' },
          { meta_name: 'twitter:card', content: 'summary' },
          { meta_name: 'twitter:site', content: '@EuropeanaEU' },
          { meta_property: 'og:sitename', content: title },
          { meta_property: 'og:description', content: description },
          { meta_property: 'og:url', content: collection_url(@collection.key) }
        ]
        head_meta << { meta_property: 'og:title', content: title } unless title.nil?
        head_meta << { meta_property: 'og:image', content: URI.join(root_url, hero[:hero_image]) } unless hero.nil?
        head_meta + super
      end
    end

    def page_title
      mustache[:page_title] ||= begin
        @landing_page.title || @collection.title
      end
    end

    def body_class
      'channel_landing'
    end

    def globalnav_options
      mustache[:globalnav_options] ||= begin
        {
          search: false,
          myeuropeana: true
        }
      end
    end

    def content
      mustache[:content] ||= begin
        {
          channel_info: {
            name: @landing_page.title,
            description: @landing_page.body,
            stats: {
              items: stylised_collection_stats
            },
            recent: @recent_additions.blank? ? nil : {
              title: t('site.collections.labels.recent'),
              items: stylised_recent_additions(@recent_additions, max: 3, skip_date: true, collection: @collection)
            },
            credits: @landing_page.credits.blank? ? {} : {
              title: t('site.collections.labels.credits'),
              items: @landing_page.credits.to_a
            }
          },
          strapline: strapline,
          hero_config: hero_config(@landing_page.hero_image),
          channel_entry: @landing_page.browse_entries.published.blank? ? nil : browse_entry_items_grouped(@landing_page.browse_entries.published, @landing_page),
          promoted: @landing_page.promotions.blank? ? nil : {
            items: promoted_items(@landing_page.promotions)
          },
          news: blog_news_items(@collection).blank? ? nil : {
            items: blog_news_items(@collection),
            blogurl: 'http://blog.europeana.eu/tag/' + @collection.key
          },
          social: @landing_page.social_media.blank? ? nil : social_media_links,
          banner: banner_content(@landing_page.banner_id),
          carousel: helpers.collection_tumblr_feed_content(@collection)
        }.reverse_merge(super)
      end
    end

    private

    def strapline
      @landing_page.strapline.present? ? @landing_page.strapline(total_item_count: number_with_delimiter(@total_item_count)) : nil
    end

    def body_cache_key
      @landing_page.cache_key
    end

    def detect_link_in_array(links, domain)
      matcher = %r(://([^/]*.)?#{domain}/)
      links.detect { |l| l.url =~ matcher }
    end

    # @todo move into {Link::SocialMedia} as {#twitter?} etc
    def social_media_links
      {
        social_title: t('global.find-us-social-media', channel: @landing_page.title),
        twitter: detect_link_in_array(@landing_page.social_media, 'twitter.com'),
        facebook: detect_link_in_array(@landing_page.social_media, 'facebook.com'),
        soundcloud: detect_link_in_array(@landing_page.social_media, 'soundcloud.com'),
        pinterest: detect_link_in_array(@landing_page.social_media, 'pinterest.com'),
        googleplus: detect_link_in_array(@landing_page.social_media, 'plus.google.com'),
        instagram: detect_link_in_array(@landing_page.social_media, 'instagram.com'),
        tumblr: detect_link_in_array(@landing_page.social_media, 'tumblr.com')
      }
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
