module Channels::Routes
  extend ActiveSupport::Concern
  def solr_document(primary_resource)
    add_routes do |options|
      args = {only: [:show]}
      args[:constraints] = options[:constraints] if options[:constraints]
      
      get "#{primary_resource}/:provider_id/:record_id", args.merge(to: "#{primary_resource}#show", as: "solr_document")
      post "#{primary_resource}/:provider_id/:record_id/track", args.merge(to: "#{primary_resource}#track", as: "track_solr_document")
    end
  end
end
Blacklight::Routes.send(:include, Channels::Routes)

Rails.application.routes.draw do
  root :to => "catalog#index"

  blacklight_for :catalog

  devise_for :users
end
