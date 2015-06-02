Blacklight::Routes.send(:include, Europeana::Portal::Routes)

Rails.application.routes.draw do
  root to: 'home#index'
  get 'search', to: 'portal#index'

  mount Spotlight::Engine, at: 'spotlight'

  blacklight_for :portal

  devise_for :users

  resources :channels, only: [:show, :index]
end
