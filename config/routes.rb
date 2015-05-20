Blacklight::Routes.send(:include, Europeana::Portal::Routes)

Rails.application.routes.draw do
  root to: 'channels#index'

  mount Spotlight::Engine, at: 'spotlight', as: 'spotlight'

  blacklight_for :catalog

  devise_for :users

  resources :channels, only: [:show, :index]

  get 'spotlight', to: 'spotlight/default#index'
end
