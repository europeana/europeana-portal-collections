module Channels
  class Show < ApplicationView
    def head_meta
      [
        { meta_name: 'description', content: truncate(strip_tags(t("site.channels.#{@channel.id}.description")), length: 350, separator: ' ') }
      ] + super
    end

    def page_title
      t('site.channels.' + @channel.id.to_s + '.title') + ' Channel - Alpha'
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
          name: t("site.channels.#{@channel.id}.title"),
          description: t("site.channels.#{@channel.id}.description"),
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
        hero_config: styleguide_hero_config(channel_content[:hero_config]),
        channel_entry: {
          items: stylised_channel_entry
        },
        promoted: {
          items: stylised_promoted
        },
        news: blog_news_items.blank? ? nil : {
          items: blog_news_items,
          blogurl: "http://blog.europeana.eu/tag/#{@channel.id}"
        },
        social: channel_content[:social]
      }.reverse_merge(helpers.content)
    end

    private

    def channel_content
      @channel_content ||= @channel.config[:content] || {}
    end

    def blog_news_items
      @blog_news_items ||= begin
        key = @channel.id.underscore.to_sym
        url = FeedCacheJob::URLS[:blog][key]
        news_items(feed_entries(url))
      end
    end

    def stylised_promoted
      return @stylised_promoted unless @stylised_promoted.blank?
      return nil unless channel_content[:promoted].present?
      @stylised_channel_entry = channel_content[:promoted].deep_dup.tap do |promoted|
        promoted.each do |item|
          item[:bg_image] = image_root + item[:bg_image] unless item[:bg_image].nil?
        end
      end
    end

    def stylised_channel_entry
      return @stylised_channel_entry unless @stylised_channel_entry.blank?
      return nil unless @channel_entry.present?
      @stylised_channel_entry = @channel_entry.deep_dup.tap do |channel_entry|
        channel_entry.each do |entry|
          entry[:count] = number_with_delimiter(entry[:count])
          entry[:image_alt] ||= nil
          entry[:image] = image_root + entry[:image] unless entry[:image].nil?
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
