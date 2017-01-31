# frozen_string_literal: true
module Galleries
  class Show < ApplicationView
    include GalleryDisplayingView

    def content
      {
        galleries_link: galleries_path,
        items: gallery_items_content,
        hero: gallery_hero_content
      }
    end

    private

    def gallery_hero_content
      {
        url: '',
        title: @gallery.title,
        subtitle: @gallery.description
      }
    end

    def gallery_items_content
      @gallery.images.map { |image| gallery_item_content(image) }
    end

    def gallery_item_content(image)
      presenter = presenter_for_gallery_image(image)
      return nil if presenter.nil?
      {
        title: presenter.title,
        creator: presenter.field_value('dataProvider'),
        thumb_url: gallery_image_thumbnail(image),
        full_url: presenter.field_value('edmPreview')
      }
    end
  end
end
