Blacklight::Routes.send(:include, Europeana::Portal::Routes)

Rails.application.routes.draw do
  root to: 'home#index'
  get 'search', to: 'portal#index'

  # monkey-patch for Spotlight's assumption of exhibit document routes using
  # SolrDocument
  Spotlight::Engine.routes.draw do
    get 'record/*id', to: 'catalog#show', as: 'exhibit_document'
    get 'record/*id/edit', to: 'catalog#edit', as: 'edit_exhibit_document'
  end
  mount Spotlight::Engine, at: 'spotlight'

  blacklight_for :portal

  devise_for :users

  resources :channels, only: [:show, :index]
end
