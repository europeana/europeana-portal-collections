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

    def galleries_social
      {
        social_title: t('global.share-galleries'),
        facebook: {
          url: 'https://www.facebook.com/Europeana',
          text: 'Facebook'
        },
        twitter: {
          url: 'https://twitter.com/Europeanaeu',
          text: 'Twitter'
        },
        pinterest: {
          url: 'https://uk.pinterest.com/europeana/',
          text: 'Pinterest'
        },
        googleplus: {
          url: 'https://plus.google.com/+europeana/posts',
          text: 'Google Plus'
        },
        tumblr: {
          url: 'http://europeanacollections.tumblr.com/',
          text: 'Tumblr'
        }
      }
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
