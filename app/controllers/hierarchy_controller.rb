# frozen_string_literal: true

##
# Just dumps out the response from the REST API hierarchy methods
class HierarchyController < ApplicationController
  before_action :check_valid_format

  respond_to :json

  # GET /record/:id/hierarchy/self
  def self
    respond_with hierarchy_for(:self)
  end

  # GET /record/:id/hierarchy/parent
  def parent
    respond_with hierarchy_for(:parent)
  end

  # GET /record/:id/hierarchy/children
  def children
    respond_with hierarchy_for(:children)
  end

  # GET /record/:id/hierarchy/preceding-siblings
  def preceding_siblings
    respond_with hierarchy_for(:preceding_siblings)
  end

  # GET /record/:id/hierarchy/following-siblings
  def following_siblings
    respond_with hierarchy_for(:following_siblings)
  end

  # GET /record/:id/hierarchy/ancestor-self-siblings
  def ancestor_self_siblings
    respond_with hierarchy_for(:ancestor_self_siblings)
  end

  protected

  def hierarchy_for(method)
    hierarchy_api_response(method).with_indifferent_access.except(:apikey).reverse_merge!(garnish)
  end

  def hierarchy_api_response(method)
    api_params = params.slice(:offset, :limit).merge(id: '/' + params[:id])
    Europeana::API.record.send(method, api_params)
  rescue Europeana::API::Errors::ResourceNotFoundError => e
    e.faraday_response.body
  end

  def garnish
    { action: [params[:action].dasherize, params[:format]].join('.'), success: true }
  end

  ##
  # Do not run expensive API/db queries if invalid format is requested
  #
  # @see ActionController::RespondWith::ClassMethods#respond_with
  def check_valid_format
    mimes = collect_mimes_from_class_level
    collector = ActionController::MimeResponds::Collector.new(mimes, request.variant)
    fail ActionController::UnknownFormat unless collector.negotiate_format(request)
  end
end
