##
# Just dumps out the response from the REST API hierarchy methods
class HierarchyController < ApplicationController
  before_action :check_valid_format

  respond_to :json

  # GET /record/:id/hierarchy/self
  def self
    respond_with record.hierarchy.self(params.slice(:offset, :limit)).merge(garnish)
  end

  # GET /record/:id/hierarchy/parent
  def parent
    respond_with record.hierarchy.self(params.slice(:offset, :limit)).merge(garnish)
  end

  # GET /record/:id/hierarchy/children
  def children
    respond_with record.hierarchy.children(params.slice(:offset, :limit)).merge(garnish)
  end

  # GET /record/:id/hierarchy/preceding-siblings
  def preceding_siblings
    respond_with record.hierarchy.preceding_siblings(params.slice(:offset, :limit)).merge(garnish)
  end

  # GET /record/:id/hierarchy/following-siblings
  def following_siblings
    respond_with record.hierarchy.following_siblings(params.slice(:offset, :limit)).merge(garnish)
  end

  # GET /record/:id/hierarchy/ancestor-self-siblings
  def ancestor_self_siblings
    respond_with record.hierarchy.ancestor_self_siblings(params.slice(:offset, :limit)).merge(garnish)
  end

  protected

  def record
    Europeana::API::Record::new('/' + params[:id])
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
    fail ActionController::UnknownFormat unless format = collector.negotiate_format(request)
  end
end
