Rails.application.routes.draw do
  root to: 'home#index'
  get 'search', to: 'portal#index'

  constraints id: %r{[^/]+/[^/]+} do
    get 'record/*id/navigation', to: 'portal#navigation', as: 'document_navigation'
    get 'record/*id/media', to: 'portal#media', as: 'document_media'
    get 'record/*id/similar', to: 'portal#similar', as: 'document_similar'

    get 'record/*id/hierarchy/self', to: 'hierarchy#self'
    get 'record/*id/hierarchy/parent', to: 'hierarchy#parent'
    get 'record/*id/hierarchy/children', to: 'hierarchy#children'
    get 'record/*id/hierarchy/preceding-siblings', to: 'hierarchy#preceding_siblings'
    get 'record/*id/hierarchy/following-siblings', to: 'hierarchy#following_siblings'
    get 'record/*id/hierarchy/ancestor-self-siblings', to: 'hierarchy#ancestor_self_siblings'

    post 'record/*id/track', to: 'portal#track', as: 'track_document'
    get 'record/*id', to: 'portal#show', as: 'document'
  end

  resources :collections, only: [:show, :index]
  resources :landing_pages, only: [:show]

  get '/channels', to: redirect('collections')
  get '/channels/:id', to: redirect('collections/%{id}')

  mount RailsAdmin::Engine => '/cms', as: 'rails_admin'
  devise_for :users

  get 'browse/colours', to: 'browse#colours'
  get 'browse/newcontent', to: 'browse#new_content'
  get 'browse/sources', to: 'browse#sources'

  get 'settings/language', to: 'settings#language'
  put 'settings/language', to: 'settings#update_language'

  # Static pages
  get '*page', to: 'portal#static', as: 'static_page'
end
