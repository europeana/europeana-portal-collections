module Templates
  module Search
    class SearchHome < ApplicationView
      def navigation
        {
          global: navigation_global,
          footer: common_footer
        }
      end

      def content
        {
          hero_config: {
            hero_image: 'sample/search_hero_1.jpg',
            brand_position: 'brand-bottomleft',
            brand_opacity: 'brand-opacity75',
            attribution_text: 'Insects and Fruit, Jan van Kessel',
            attribution_url: 'http://www.europeana.eu/portal/record/90402/SK_A_793.html',
            license_CC_ND_NC_SA: false,
            license_public: true
          },
          strapline: t('site.home.strapline', total_item_count: total_item_count),
          important_removed: {
            text: 'Europeana stories are now in Google’s Field Trip app',
            url: 'http://blog.europeana.eu/2015/03/its-your-world-explore-it-europeana-stories-now-in-googles-field-trip-app/'
          },
          promoted: config[:promoted],
          news: blog_news_items.blank? ? nil : {
            items: blog_news_items,
            blogurl: 'http://blog.europeana.eu/'
          }
        }
      end

      private

      def config
        Rails.application.config.channels[:home]
      end

      def blog_news_items
        @blog_news_items ||= news_items(@blog_items)
      end
    end
  end
end
