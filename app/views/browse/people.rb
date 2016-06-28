module Browse
  class People < ApplicationView
    include CollectionFilterableView
    include BrowseEntryDisplayingView

    def page_title
      mustache[:page_title] ||= begin
        [t('site.browse.people.title'), site_title].join(' - ')
      end
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
      'browse/people' + (@collection.present? ? '/' + @collection.key : '') + '-' + @people.map(&:updated_at).max.to_i.to_s
    end
  end
end
