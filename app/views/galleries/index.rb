# frozen_string_literal: true
module Galleries
  class Index < ApplicationView
    include GalleryDisplayingView

    def content
      {
        galleries: galleries_content
      }
    end

    private

    def galleries_content
      @galleries.map { |gallery| gallery_content(gallery) }
    end

    def gallery_content(gallery)
      {
        title: gallery.title,
        link: gallery_path(gallery),
        count: gallery.images.size,
        images: gallery_images_content(gallery)
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
