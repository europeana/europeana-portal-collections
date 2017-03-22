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

    def content
      mustache[:content] ||= begin
        {
          title: t('site.events.list.page-title'),
          text: '<ol>' + @events.map { |event| '<li>' + link_to(event.title, event_path(event)) + '</li>' }.join + '</ol>'
        }.reverse_merge(super)
      end
    end

    protected

    def paginated_set
      @events
    end
  end
end
