# frozen_string_literal: true
##
# Handles listing and display of events retrieved from Europeana Pro via
# JSON API.
#
# @todo Exception handling when `JsonApiClient` requests fail
# @todo Filter for events relevant to the portal
class EventsController < ApplicationController
  include HomepageHeroImage
  include PaginatedController
  include ProJsonApiConsumer

  helper_method :order_filters, :selected_order

  self.pagination_per_default = 6

  def index
    @events = Pro::Event.includes(:locations, :network).where(pro_json_api_filters).
              where(past_future_filter).
              order('-end_event').page(pagination_page).per(pagination_per).all
    @hero_image = homepage_hero_image
  end

  def show
    results = Pro::Event.includes(:locations, :network).where(pro_json_api_filters).
              where(slug: params[:slug])
    @event = results.first

    fail JsonApiClient::Errors::NotFound.new(results.links.links['self']) if @event.nil?
  end

  protected

  def past_future_filter
    {
      end_event: (order_filters[selected_order] || {})[:filter]
    }
  end

  def selected_order
    (params[:order] || 'future').to_sym
  end

  def order_filters
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
