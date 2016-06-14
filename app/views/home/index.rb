module Home
  class Index < ApplicationView
    def page_title
      'Europeana Collections'
    end

    def js_slsb_ld
      {
        context: 'http://schema.org',
        type: 'WebSite',
        url: root_url,
        potentialAction: {
          type: 'SearchAction',
          target: root_url + 'search?q={q}',
          query_input: 'required name=q'
        }
      }
    end

    def content
      mustache[:content] ||= begin
        {
          hero_config: hero_config(@landing_page.hero_image),
          strapline: @landing_page.strapline(total_item_count: total_item_count),
          promoted: @landing_page.promotions.blank? ? nil : promoted_items(@landing_page.promotions),
          news: blog_news_items(@collection).blank? ? nil : {
            items: blog_news_items(@collection),
            blogurl: Cache::FeedJob::URLS[:blog][:all].sub('/feed', '')
          },
          banner: banner_content(@landing_page.banner_id)
        }.reverse_merge(helpers.content)
      end
    end

    def head_meta
      mustache[:head_meta] ||= begin
        title = page_title
        description = truncate(@landing_page.strapline(total_item_count: @europeana_item_count), length: 350, separator: ' ')
        description = description.strip! || description
        hero = hero_config(@landing_page.hero_image)
        head_meta = [
          { meta_name: 'description', content: description },
          { meta_property: 'fb:appid', content: '185778248173748' },
          { meta_name: 'twitter:card', content: 'summary' },
          { meta_name: 'twitter:site', content: '@EuropeanaEU' },
          { meta_property: 'og:sitename', content: title },
          { meta_property: 'og:description', content: description },
          { meta_property: 'og:url', content: root_url }
        ]
        head_meta << { meta_property: 'og:title', content: title } unless title.nil?
        head_meta << { meta_property: 'og:image', content: URI.join(root_url, hero[:hero_image]) } unless hero.nil?
        head_meta + super
      end
    end

    private

    def body_cache_key
      @landing_page.cache_key
    end
  end
end
