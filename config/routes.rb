Blacklight::Routes.send(:include, BlacklightRoutes)

Rails.application.routes.draw do
  root to: 'home#index'
  get 'search', to: 'portal#index'

  blacklight_for :portal

  resources :channels, only: [:show, :index]
  resources :landing_pages, only: [:show]

  # Static pages
  get ':page', to: 'portal#static', constraints: { page: %r{(about|channels/music/about)} }

  mount RailsAdmin::Engine => '/cms', as: 'rails_admin'
  devise_for :users
end
