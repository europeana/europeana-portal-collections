# frozen_string_literal: true

module Galleries
  class Index < ApplicationView
    include GalleryDisplayingView
    include PaginatedView

    def bodyclass
      'channel_landing'
    end

    def page_content_heading
      t('global.galleries')
    end

    def head_links
      mustache[:head_links] ||= begin
        { items: [{ rel: 'alternate', type: 'application/rss+xml', href: galleries_url(format: 'rss') }] + super[:items] }
      end
    end

    def head_meta
      mustache[:head_meta] ||= begin
        gallery_head_meta + [
          { meta_name: 'description', content: t('site.galleries.description') },
          { meta_property: 'og:description', content: t('site.galleries.description') },
          { meta_property: 'og:image', content: @hero_image&.file&.url },
          { meta_property: 'og:title', content: page_title }
        ] + super
      end
    end

    def galleries_social
      gallery_social_links.merge(social_title: t('site.galleries.share.other'))
    end

    def content
      mustache[:content] ||= begin
        {
          hero: hero_content,
          galleries: galleries_content,
          social: galleries_social,
          gallery_filter_options: galleries_topics
        }
      end
    end

    def navigation
      mustache[:navigation] ||= begin
        {
          pagination: pagination_navigation
        }.reverse_merge(super)
      end
    end

    protected

    def paginated_set
      @galleries
    end

    def hero_content
      {
        url: @hero_image&.file&.url,
        title: t('global.galleries'),
        subtitle: ''
      }
    end

    def galleries_topics
      @topics ||= {
        options: gallery_topic_options
      }
    end

    def gallery_topic_options
      sorted_gallery_topic_options.tap do |options|
        options.unshift(label: t('global.actions.filter-all'), value: 'all')
        options.unshift(options.detect { |option| option[:value] == @selected_topic })
        options.uniq!
      end
    end

    def published_gallery_topic_options
      Topic.with_published_galleries.map do |topic|
        {
          label: topic.label,
          value: topic.to_param
        }
      end
    end

    # Sort all published gallery topic options by their translated labels.
    def sorted_gallery_topic_options
      published_gallery_topic_options.sort_by { |option| option[:label] }
    end

    def galleries_content
      @galleries.map { |gallery| gallery_content(gallery) }
    end
  end
end
