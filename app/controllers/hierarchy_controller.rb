##
# Just dumps out the response from the REST API hierarchy methods
class HierarchyController < ApplicationController
  # GET /record/:id/hierarchy/self
  def self
    data = record.hierarchy.self(params.slice(:offset, :limit))
    respond_to do |format|
      format.json { render json: data }
    end
  end

  # GET /record/:id/hierarchy/parent
  def parent
    data = record.hierarchy.self(params.slice(:offset, :limit))
    respond_to do |format|
      format.json { render json: data }
    end
  end

  # GET /record/:id/hierarchy/children
  def children
    data = record.hierarchy.children(params.slice(:offset, :limit))
    respond_to do |format|
      format.json { render json: data }
    end
  end

  # GET /record/:id/hierarchy/preceding-siblings
  def preceding_siblings
    data = record.hierarchy.preceding_siblings(params.slice(:offset, :limit))
    respond_to do |format|
      format.json { render json: data }
    end
  end

  # GET /record/:id/hierarchy/following-siblings
  def following_siblings
    data = record.hierarchy.preceding_siblings(params.slice(:offset, :limit))
    respond_to do |format|
      format.json { render json: data }
    end
  end

  # GET /record/:id/hierarchy/ancestor-self-siblings
  def ancestor_self_siblings
    data = record.hierarchy.ancestor_self_siblings(params.slice(:offset, :limit))
    respond_to do |format|
      format.json { render json: data }
    end
  end

  protected

  def record
    Europeana::API::Record::new('/' + params[:id])
  end
end
