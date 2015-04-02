Blacklight::Routes.send(:include, Europeana::Portal::Routes)

Rails.application.routes.draw do
  root to: 'channels#index'

  blacklight_for :catalog
  resources :channels, only: [:show, :index]
end
