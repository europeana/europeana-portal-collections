# frozen_string_literal: true
module Galleries
  class Index < ApplicationView
    include GalleryDisplayingView

    def bodyclass
      'channel_landing'
    end

    def page_title
      mustache[:page_title] ||= [t('global.galleries'), site_title].join(' - ')
    end

    def js_vars
      [{ name: 'pageName', value: 'collections/galleries' }]
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
      {
        pagination: {
          prev_url: prev_page.url,
          next_url: next_page.url,
          is_first_page: @galleries.first_page?,
          is_last_page: @galleries.last_page?,
          pages: navigation_pagination_pages
        }
      }.reverse_merge(super)
    end

    private

    def navigation_pagination_pages
      (1..@galleries.total_pages).map do |number|
        page = Kaminari::Helpers::Page.new(self, page: number)
        {
          url: page.url,
          index: number,
          is_current: number == @galleries.current_page
        }
      end
    end

    def prev_page
      @prev_page ||= Kaminari::Helpers::PrevPage.new(self, current_page: @galleries.current_page)
    end

    def next_page
      @next_page ||= Kaminari::Helpers::NextPage.new(self, current_page: @galleries.current_page)
    end

    def hero_content
      {
        url: @hero_image.file.present? ? @hero_image.file.url : nil,
        title: 'Galleries', # @todo get this from Localeapp
        subtitle: ''
      }
    end

    def galleries_topics
      @topics ||= {
        options: Topic.with_published_galleries.map do |topic|
          {
            label: topic.label,
            value: topic.to_param
          }
        end.unshift(label: 'All', value: 'all')
      }
      @topics[:options].unshift(@topics[:options].select { |topic| topic[:value] == @selected_topic }.first).uniq!
      @topics
    end

    def galleries_content
      @galleries.map { |gallery| gallery_content(gallery) }
    end

    def gallery_content(gallery)
      {
        title: gallery.title,
        link: gallery_path(gallery),
        count: gallery.images.size,
        images: gallery_images_content(gallery),
        clicktip: {
          tooltip_text: gallery.description
        }
      }
    end

    def gallery_images_content(gallery)
      gallery.images.first(3).map { |image| gallery_image_content(image) }
    end

    def gallery_image_content(image)
      {
        index: image.position,
        url: gallery_image_thumbnail(image)
      }
    end
  end
end
