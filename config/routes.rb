Blacklight::Routes.send(:include, BlacklightRoutes)

Rails.application.routes.draw do
  root to: 'home#index'
  get 'search', to: 'portal#index'

  blacklight_for :portal

  resources :channels, only: [:show, :index]
end
