module Explore
  class Periods < ApplicationView
    include CollectionFilterableView
    include BrowseEntryDisplayingView

    def page_title
      mustache[:page_title] ||= begin
        [t('site.browse.periods.title'), site_title].join(' - ')
      end
    end

    def content
      mustache[:content] ||= begin
        {
            title: page_title,
            description: t('site.browse.periods.description'),
            browse_entries: @periods.blank? ? nil : {
                items: browse_entry_items(@periods)
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
      'explore/people' + (@collection.present? ? '/' + @collection.key : '') + '-' + @periods.map(&:updated_at).max.to_i.to_s
    end
  end
end
