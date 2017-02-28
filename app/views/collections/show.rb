module Collections
  class Show < ApplicationView
    include BrowsableView
    include BrowseEntryDisplayingView
    include FacetEntryPointDisplayingView
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
   
    def collection_title
   	  @collection.title
    end

    def globalnav_options
      mustache[:globalnav_options] ||= begin
        {
          search: false,
          myeuropeana: true
        }
      end
    end

    def include_nav_searchbar
      mustache[:include_nav_searchbar] ||= begin
        @landing_page.settings_layout_type == 'browse'
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
          "layout_#{@landing_page.settings_layout_type}".to_sym => true,
          strapline: strapline,
          hero_config: hero_config(@landing_page.hero_image),
          entry_points: @landing_page.settings_layout_type == 'browse' ? facet_entry_items_grouped(@landing_page) : [],
          preview_search_data: preview_search_data,
          preview_search_data_present: preview_search_data.present?,
          channel_entry: @landing_page.browse_entries.published.blank? ? nil : browse_entry_items_grouped(@landing_page.browse_entries.published, @landing_page),
          promoted: @landing_page.promotions.blank? ? nil : {
            items: promoted_items(@landing_page.promotions)
          },
          news: blog_news_items(@collection).blank? ? nil : {
            items: blog_news_items(@collection),
            blogurl: 'http://blog.europeana.eu/tag/' + @collection.key
          },
          newsletter: newsletter_content,
          social: @landing_page.social_media.blank? ? nil : social_media_links,
          banner: banner_content(@landing_page.banner_id),
          carousel: carousel_data
        }.reverse_merge(super)
      end
    end

    def version
      { is_alpha: beta_collection?(@collection) }
    end

    private

    def newsletter_content
      return nil unless @landing_page.newsletter_url.present?
      {
        form: {
          action: @landing_page.newsletter_url,
          language_op: false,
          placeholder: t('global.email-address')
        },
        labels: {
          heading: t("global.newsletter.#{@collection.key}.heading"),
          subheading: t("global.newsletter.#{@collection.key}.subheading")
        }
      }
    end

    def carousel_data
      case @landing_page.settings[:layout_type]
        when 'default'
          helpers.collection_tumblr_feed_content(@collection)
        when 'browse'
          helpers.collection_feeds_content(@collection)
      end
    end

    def strapline
      @landing_page.strapline.present? ? @landing_page.strapline(total_item_count: number_with_delimiter(@total_item_count)) : nil
    end

    def body_cache_key
      @landing_page.cache_key
    end

    def social_media_links
      {
        social_title: t('global.follow-channel', channel: @landing_page.title),
        style_blue: true,
        twitter: social_media_link_for(:twitter),
        facebook: social_media_link_for(:facebook),
        soundcloud: social_media_link_for(:soundcloud),
        pinterest: social_media_link_for(:pinterest),
        googleplus: social_media_link_for(:googleplus),
        instagram: social_media_link_for(:instagram),
        tumblr: social_media_link_for(:tumblr),
        linkedin: social_media_link_for(:linkedin)
      }
    end

    def social_media_link_for(provider)
      @landing_page.social_media.detect(&:"#{provider}?")
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

    # @todo refactor to:
    # - make modular have this be a concern
    # - lookup proper search title & type using labeling from  presenters/concerns/facet/labelling.rb
    # - refactor facet_entry_field_title to not be called for each facet entry
    def preview_search_data
      return nil if @landing_page.facet_entries.blank?

      @landing_page.facet_entries.map do |facet_entry|
        {
          preview_search_title: facet_entry.title,
          preview_search_type: facet_entry_field_title(facet_entry),
          preview_search_url: browse_entry_url(facet_entry, @landing_page, format: 'json'),
          preview_search_more_link: browse_entry_url(facet_entry, @landing_page)
        }
      end
    end

    def facet_entry_field_title(facet_entry)
      ff = Europeana::Blacklight::Response::Facets::FacetField.new(facet_entry.facet_field, [])
      presenter = FacetPresenter.build(ff, controller)
      presenter.facet_title || facet_entry.facet_field
    end
  end
end
