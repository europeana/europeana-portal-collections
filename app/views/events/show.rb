# frozen_string_literal: true
module Events
  class Show < ApplicationView
    def page_title
      mustache[:page_title] ||= [@event.title, site_title].join(' - ')
    end

    def event_title
      presenter.title
    end

    def content
      mustache[:content] ||= begin
        {
          body: presenter.body,
          has_authors: @event.has_authors?,
          authors: presenter.authors,
          has_tags: @event.has_taxonomy?(:tags),
          tags: presenter.tags,
          label: presenter.label,
          event_date: presenter.date_range(:start_event, :end_event),
          date: presenter.date_range(:start_event, :end_event),
          introduction: presenter.introduction,
          event_image: presenter.image(:url, :teaser_image),
          geolocation: presenter.geolocation,
          read_time: presenter.read_time
        }
      end
    end

    def navigation
      mustache[:navigation] ||= begin
        {
          back_url: events_path,
          back_label: t('site.events.list.page-title')
        }.reverse_merge(super)
      end
    end

    protected

    def presenter
      @presenter ||= ProResourcePresenter.new(self, @event)
    end
  end
end
