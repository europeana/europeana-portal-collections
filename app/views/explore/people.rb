# frozen_string_literal: true

module Explore
  class People < ApplicationView
    include CollectionFilterableView
    include BrowseEntryDisplayingView

    def page_content_heading
      t('site.browse.people.title')
    end

    def content
      mustache[:content] ||= begin
        {
          title: page_title,
          description: t('site.browse.people.description'),
          browse_entries: @people.blank? ? nil : {
            items: browse_entry_items(@people)
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
      'explore/people' + (@collection.present? ? '/' + @collection.key : '') + '-' + @people.map(&:updated_at).max.to_i.to_s
    end
  end
end
