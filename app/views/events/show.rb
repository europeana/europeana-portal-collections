# frozen_string_literal: true
module Events
  class Show < ApplicationView
    def page_title
      mustache[:page_title] ||= [@event.title, site_title].join(' - ')
    end

    def content
      mustache[:content] ||= begin
        {
          title: @event.title,
          text: @event.introduction + @event.body
        }.reverse_merge(super)
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
  end
end
