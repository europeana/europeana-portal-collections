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

  self.pagination_per_default = 6

  def index
    @events = Pro::Event.includes(:locations, :network).where(pro_json_api_filters).
              # Uncomment to restrict to current and future events, but only
              # when UI is in place to switch to past events, and accommodate
              # that by param in this controller.
              # where(end_event: ">=" + Date.today.strftime).
              order('-end_event').page(pagination_page).per(pagination_per).all
    @hero_image = homepage_hero_image
  end

  def show
    results = Pro::Event.includes(:locations, :network).where(pro_json_api_filters).
              where(slug: params[:slug])
    @event = results.first

    fail JsonApiClient::Errors::NotFound.new(results.links.links['self']) if @event.nil?
  end
end
