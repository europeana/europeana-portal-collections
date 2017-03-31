# frozen_string_literal: true
module Events
  class Index < ApplicationView
    include PaginatedJsonApiResultSetView

    def page_title
      mustache[:page_title] ||= begin
        [t('site.events.list.page-title'), site_title].join(' - ')
      end
    end

    def navigation
      mustache[:navigation] ||= begin
        {
          pagination: pagination_navigation
        }.reverse_merge(super)
      end
    end

    def hero
      mustache[:hero] ||= begin
        {
          hero_image: @hero_image.present? && @hero_image.file.present? ? @hero_image.file.url : nil
        }
      end
    end

    def event_items
      @events.map { |event| event_item(event) }
    end

    protected

    def event_item(event)
      presenter = ProResourcePresenter.new(self, event)
      {
        title: presenter.title,
        object_url: event_path(slug: event.slug),
        description: presenter.teaser,
        date: presenter.date_range(:start_event, :end_event),
        location: presenter.location_name,
        img: presenter.image(:thumbnail, :teaser_image),
        label: presenter.label,
        tags: presenter.tags
      }
    end

    def paginated_set
      @events
    end
  end
end
