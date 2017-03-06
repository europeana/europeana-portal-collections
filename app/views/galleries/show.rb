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

    def head_meta
      mustache[:head_meta] ||= begin
        description = @gallery.description
        @gallery.description.blank? ? t('site.galleries.description-default') : @gallery.description
        head_meta = gallery_head_meta + [
          { meta_name: 'description', content: description },
          { meta_property: 'og:description', content: description },
          { meta_property: 'og:image', content: gallery_items_content.first[:full_url] },
          { meta_property: 'og:title', content: @gallery.title },
          { meta_property: 'og:sitename', content: @gallery.title }
        ]
        head_meta + super
      end
    end

    def gallery_social
      gallery_social_links.merge(social_title: t('site.galleries.share.one'))
    end

    def content
      mustache[:content] ||= begin
        {
          galleries_link: galleries_path,
          items: gallery_items_content,
          hero: gallery_hero_content,
          social: gallery_social
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

    def data_provider_logo_url(presenter)
      data_provider_name = presenter.field_value('dataProvider')
      provider = DataProvider.find_by_name(data_provider_name)
      return nil unless provider.present? && provider.image.present?
      provider.image.url(:medium)
    end

    def gallery_item_content(image)
      presenter = presenter_for_gallery_image(image)
      return nil if presenter.nil?
      {
        title: presenter.title,
        creator: presenter.field_value('dataProvider'),
        thumb_url: gallery_image_thumbnail(image),
        full_url: presenter.field_value('aggregations.edmIsShownBy'),
        rights: presenter.simple_rights_label_data,
        url_item: image.portal_url,
        url_collection: search_path(q: "europeana_collectionName:#{presenter.field_value('europeanaCollectionName')}"),
        institution_logo: data_provider_logo_url(presenter)
      }
    end
  end
end
