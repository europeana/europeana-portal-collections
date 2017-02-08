# frozen_string_literal: true
module Galleries
  class Show < ApplicationView
    include GalleryDisplayingView

    def bodyclass
      'channel_landing'
    end

    def page_title
      mustache[:page_title] ||= [@gallery.title, site_title].join(' - ')
    end

    def js_vars
      [{ name: 'pageName', value: 'collections/galleries' }]
    end

    def content
      mustache[:content] ||= begin
        {
          galleries_link: galleries_path,
          items: gallery_items_content,
          hero: gallery_hero_content,
          social: galleries_social
        }
      end
    end

    def body_cache_key
      'explore/' + @gallery.cache_key
    end

    private

    def gallery_hero_content
      {
        url: gallery_items_content.first[:full_url],
        title: @gallery.title,
        subtitle: @gallery.description
      }
    end

    def gallery_items_content
      mustache[:gallery_items_content] ||= @gallery.images.map { |image| gallery_item_content(image) }
    end

    def gallery_item_content(image)
      presenter = presenter_for_gallery_image(image)
      return nil if presenter.nil?
      {
        title: presenter.title,
        creator: presenter.field_value('dataProvider'),
        thumb_url: gallery_image_thumbnail(image),
        full_url: presenter.field_value('aggregations.edmIsShownBy')
      }
    end
  end
end
