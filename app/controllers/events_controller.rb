# frozen_string_literal: true
##
# Handles listing and display of events retrieved from Europeana Pro via
# JSON API.
#
# @todo Exception handling when `JsonApiClient` requests fail
# @todo Extract pagination into a controller concern
class EventsController < ApplicationController
  def index
    @pagination_page = events_page
    @pagination_per = events_per
    @events = pro_events.page(@pagination_page).per(@pagination_per).all
  end

  def show
    @event = pro_events.where(slug: params[:slug]).first
  end

  protected

  def pro_events
    Pro::Event.includes(:network, :persons)
  end

  def events_page
    (params[:page] || 1).to_i
  end

  def events_per
    (params[:per_page] || 6).to_i
  end
end
