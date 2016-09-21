Rails.application.routes.draw do
  root to: 'locale#index'

  scope '/:locale', constraints: { locale: /[a-z]{2}/ } do
    get '', to: 'home#index', as: 'home'
    get 'search', to: 'portal#index'

    constraints id: %r{[^/]+/[^/]+} do
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

    resources :collections, only: [:show, :index] do
      get 'tumblr', on: :member
    end

    get 'channels', to: redirect('%{locale}/collections')
    get 'channels/:id', to: redirect('%{locale}/collections/%{id}')

    mount RailsAdmin::Engine => '/cms', as: 'rails_admin'
    devise_for :users

    get 'browse/agents', to: redirect('%{locale}/explore/people')
    get 'browse/colours', to: redirect('%{locale}/explore/colours')
    get 'browse/concepts', to: redirect('%{locale}/explore/topics')
    get 'browse/newcontent', to: redirect('%{locale}/explore/newcontent')
    get 'browse/people', to: redirect('%{locale}/explore/people')
    get 'browse/sources', to: redirect('%{locale}/explore/sources')
    get 'browse/topics', to: redirect('%{locale}/explore/topics')
    get 'browse/periods', to: redirect('%{locale}/explore/periods')

    get 'explore/colours', to: 'explore#colours'
    get 'explore/newcontent', to: 'explore#new_content'
    get 'explore/people', to: 'explore#people'
    get 'explore/sources', to: 'explore#sources'
    get 'explore/topics', to: 'explore#topics'
    get 'explore/periods', to: 'explore#periods'

    mount Europeana::FeedbackButton::Engine, at: '/'

    get 'debug/exception', to: 'debug#exception'

    # Static pages
    get '*page', to: 'pages#show', as: 'static_page'
  end

  put 'locale', to: 'locale#update'
  get '*path', to: 'locale#show'
end
