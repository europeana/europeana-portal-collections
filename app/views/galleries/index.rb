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

    def content
      mustache[:content] ||= begin
        {
          hero: hero_content,
          galleries: galleries_content,
          social: galleries_social
        }
      end
    end

    private

    def hero_content
      {
        url: @hero_image.file.present? ? @hero_image.file.url : nil,
        title: 'Galleries', # @todo get this from Localeapp
        subtitle: ''
      }
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
  end
end
