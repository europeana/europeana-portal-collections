# frozen_string_literal: true
##
# Handles listing and display of events retrieved from Europeana Pro via
# JSON API.
#
# @todo Exception handling when `JsonApiClient` requests fail
# @todo Filter for events relevant to the portal
class EventsController < ApplicationController
  include CacheHelper
  include HomepageHeroImage
  include PaginatedController
  include ProJsonApiConsumer

  helper_method :past_future_filters, :selected_past_future

  self.pagination_per_default = 6

  attr_reader :body_cache_key
  helper_method :body_cache_key

  def index
    @events = Pro::BlogEvent.includes(:persons).where(pro_json_api_filters).
              where(pro_json_api_past_future_filter).order(end_event: :desc).
              page(pagination_page).per(pagination_per).all
    @hero_image = homepage_hero_image

    respond_to do |format|
      format.html
      format.rss
    end
  end

  def show
    @body_cache_key = "events/#{params[:slug]}.#{request.format.to_sym}"

    unless body_cached?
      results = Pro::BlogEvent.includes(:persons).where(pro_json_api_filters).
                where(slug: params[:slug])
      @event = results.first
      fail JsonApiClient::Errors::NotFound.new(results.links.links['self']) if @event.nil?
    end

    respond_to do |format|
      format.html
    end
  end

  protected

  def pro_json_api_past_future_filter
    {
      end_event: (past_future_filters[selected_past_future] || {})[:filter]
    }
  end

  def selected_past_future
    (params[:sort] || 'future').to_sym
  end

  def past_future_filters
    date = Date.today.strftime
    {
      future: {
        filter: ">=#{date}",
        label: t('site.events.list.future')
      },
      past: {
        filter: "<#{date}",
        label: t('site.events.list.past')
      }
    }
  end
end
