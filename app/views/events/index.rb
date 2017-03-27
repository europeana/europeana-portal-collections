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
      {
        title: event.title,
        description: event.teaser,
        date: event_date(event),
        location: event_location(event),
        img: event_image(event),
        label: nil,
        tags: event_tags(event)
      }
    end

    def event_image(event)
      return nil unless event.has_teaser_image?
      return nil unless event.teaser_image.key?(:thumbnail) && event.teaser_image[:thumbnail].present?

      {
        src: event.teaser_image[:thumbnail]
      }
    end

    def event_location(event)
      event.includes?(:locations) ? event.locations.first.title : nil
    end

    def event_tags(event)
      return nil unless event.has_taxonomy?(:tags)

      { items: event_tags_items(event) }
    end

    def event_tags_items(event)
      return nil unless event.has_taxonomy?(:tags)

      event.taxonomy[:tags].map do |_pro_path, tag|
        {
          # url: events_path(tag: tag),
          text: tag
        }
      end
    end

    def fmt_datetime_as_date(datetime)
      return nil if datetime.nil?
      DateTime.parse(datetime).strftime('%-d %B, %Y') # @todo Localeapp the date format
    end

    def event_date(event)
      start_date = fmt_datetime_as_date(event_start_datetime(event))
      end_date = fmt_datetime_as_date(event_end_datetime(event))
      return nil if [start_date, end_date].all?(&:blank?)
      [start_date, end_date].compact.uniq.join(' - ')
    end

    def event_start_datetime(event)
      event.respond_to?(:start_event) ? event.start_event : nil
    end

    def event_end_datetime(event)
      event.respond_to?(:end_event) ? event.end_event : nil
    end

    def paginated_set
      @events
    end
  end
end
