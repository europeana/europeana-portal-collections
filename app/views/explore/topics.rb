# frozen_string_literal: true

module Explore
  class Topics < ApplicationView
    include CollectionFilterableView
    include BrowseEntryDisplayingView

    def page_content_heading
      t('site.browse.topics.title')
    end

    def content
      mustache[:content] ||= begin
        {
          title: page_title,
          description: t('site.browse.topics.description'),
          browse_entries: @topics.blank? ? nil : {
            items: browse_entry_items(@topics)
          },
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
      'explore/topics' + (@collection.present? ? '/' + @collection.key : '') + '-' + @topics.map(&:updated_at).max.to_i.to_s
    end
  end
end
