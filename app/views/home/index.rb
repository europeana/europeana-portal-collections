module Home
  class Index < ApplicationView
    def page_title
      'Europeana Collections - Alpha'
    end

    def content
      {
        hero_config: hero_config(@landing_page.hero_image),
        strapline: t('site.home.strapline', total_item_count: total_item_count),
        promoted: @landing_page.promotions.blank? ? nil : promoted_items(@landing_page.promotions),
        news: blog_news_items.blank? ? nil : {
          items: blog_news_items,
          blogurl: Cache::FeedJob::URLS[:blog][:all]
        }
      }.reverse_merge(helpers.content)
    end

    def head_meta
      [
        { meta_name: 'description', content: truncate(I18n.t('site.home.strapline', total_item_count: @europeana_item_count), length: 350, separator: ' ') }
      ] + super
    end

    private

    def blog_news_items
      @blog_news_items ||= news_items(feed_entries(Cache::FeedJob::URLS[:blog][:all]))
    end
  end
end
