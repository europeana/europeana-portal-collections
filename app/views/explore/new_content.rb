# frozen_string_literal: true

module Explore
  class NewContent < ApplicationView
    include CollectionFilterableView

    def page_content_heading
      t('site.browse.newcontent.title')
    end

    def content
      mustache[:content] ||= begin
        {
          title: page_title,
          description: t('site.browse.newcontent.description'),
          recent: @providers.blank? ? nil : {
            title: ' ',
            items: stylised_recent_additions(@providers, max: 1000, from: :same, collection: @collection),
            tableh1: t('site.browse.newcontent.tableh1'),
            tableh2: t('site.browse.newcontent.tableh2'),
            tableh3: t('site.browse.newcontent.tableh3')
          }
        }
      end
    end

    def head_meta
      mustache[:head_meta] ||= begin
        [
          { meta_name: 'description', content: page_title }
        ] + super
      end
    end

    private

    def body_cache_key
      'explore/newcontent' + (@collection.present? ? '/' + @collection.key : '')
    end
  end
end
