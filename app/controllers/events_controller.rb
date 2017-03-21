# frozen_string_literal: true
##
# Handles listing and display of events retrieved from Europeana Pro via
# JSON API.
#
# @todo Exception handling when `JsonApiClient` requests fail
class EventsController < ApplicationController
  include PaginatedController

  self.pagination_per_default = 6

  def index
    @events = pro_events.page(pagination_page).per(pagination_per).all
  end

  def show
    @event = pro_events.where(slug: params[:slug]).first
  end

  protected

  def pro_events
    Pro::Event.includes(:network, :persons)
  end
end
