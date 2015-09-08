module Home
  class Index < ApplicationView
    def page_title
      'Europeana Collections - Alpha'
    end

    def content
      {
        hero_config: helpers.styleguide_hero_config(config[:content][:hero_config]),
        strapline: t('site.home.strapline', total_item_count: total_item_count),
        promoted: stylised_promoted,
        news: blog_news_items.blank? ? nil : {
          items: blog_news_items,
          blogurl: 'http://blog.europeana.eu/'
        }
      }.merge(helpers.content)
    end

    private

     def stylised_promoted
      return @stylised_promoted unless @stylised_promoted.blank?
      return nil unless config[:content][:promoted].present?
      @stylised_channel_entry = config[:content][:promoted].deep_dup.tap do |promoted|
        promoted.each do |item|
          item[:bg_image] = image_root + item[:bg_image] unless item[:bg_image].nil?
        end
      end
    end

    def config
      Rails.application.config.x.channels[:home]
    end

    def blog_news_items
      @blog_news_items ||= news_items(@blog_items)
    end
  end
end
