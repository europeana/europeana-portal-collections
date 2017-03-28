# frozen_string_literal: true
##
# Handles listing and display of events retrieved from Europeana Pro via
# JSON API.
#
# @todo Exception handling when `JsonApiClient` requests fail
class EventsController < ApplicationController
  include HomepageHeroImage
  include PaginatedController

  self.pagination_per_default = 6

  def index
    @events = Pro::Event.includes(:locations, :network).
              order('-end_event').
              page(pagination_page).per(pagination_per).all
    @hero_image = homepage_hero_image
  end

  def show
    @event = Pro::Event.includes(:locations, :network).
             where(slug: params[:slug]).first

    fail JsonApiClient::Errors::NotFound.new(request.original_url) if @event.nil?
  end
end
