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

  self.pagination_per_default = 6

  attr_reader :body_cache_key
  helper_method :body_cache_key

  def index
    @events = Pro::Event.includes(:locations, :network).
              order('-end_event').
              # Uncomment to restrict to events tagged "culturelover"
              # where(filters).
              # Uncomment to restrict to current and future events, but only
              # when UI is in place to switch to past events, and accommodate
              # that by param in this controller.
              # where(end_event: ">=" + Date.today.strftime).
              page(pagination_page).per(pagination_per).all
    @hero_image = homepage_hero_image

    respond_to do |format|
      format.html
    end
  end

  def show
    @body_cache_key = "events/#{params[:slug]}.#{request.format.to_sym}"

    unless body_cached?
      results = Pro::Event.includes(:locations, :network).
                # Uncomment to restrict to events tagged "culturelover"
                # where(filters).
                where(slug: params[:slug])
      @event = results.first
      fail JsonApiClient::Errors::NotFound.new(results.links.links['self']) if @event.nil?
    end

    respond_to do |format|
      format.html
    end
  end

  protected

  def filters
    {
      tags: 'culturelover'
    }
  end
end
