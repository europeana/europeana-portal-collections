module Channels::Routes
  extend ActiveSupport::Concern
  def solr_document(primary_resource)
    add_routes do |options|
      args = { only: [:show] }
      args[:constraints] = options[:constraints] if options[:constraints]
      
      get "record/:provider_id/:record_id", args.merge(to: "#{primary_resource}#show", as: "solr_document")
      post "record/:provider_id/:record_id/track", args.merge(to: "#{primary_resource}#track", as: "track_solr_document")
    end
  end
  
  def bookmarks(_)
    add_routes do |options|
      delete "bookmarks/clear", to: "bookmarks#clear", as: "clear_bookmarks"
      
      resources :bookmarks, only: [ :index, :create, :new ]
      get "bookmarks/:provider_id/:record_id/edit(.:format)", to: "bookmarks#edit", as: "edit_bookmark"
      get "bookmarks/:provider_id/:record_id(.:format)", to: "bookmarks#show", as: "bookmark"
      patch "bookmarks/:provider_id/:record_id(.:format)", to: "bookmarks#update"
      put "bookmarks/:provider_id/:record_id(.:format)", to: "bookmarks#update"
      delete "bookmarks/:provider_id/:record_id(.:format)", to: "bookmarks#destroy"
    end
  end
end
Blacklight::Routes.send(:include, Channels::Routes)

Rails.application.routes.draw do
  root :to => "channels#index"

  devise_for :users
  
  blacklight_for :catalog
  resources :channels, only: [ :show, :index ]
end
