# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'locale#index'

  scope '/:locale', constraints: { locale: /[a-z]{2}/ } do
    get '', to: 'home#index', as: 'home'
    get 'search', to: 'portal#index'

    constraints id: %r{[^/]+/[^/]+} do
      get 'record/*id/annotations', to: 'portal#annotations', as: 'document_annotations'
      get 'record/*id/exhibitions', to: 'portal#exhibitions', as: 'document_exhibitions'
      get 'record/*id/galleries', to: 'portal#galleries', as: 'document_galleries'
      get 'record/*id/media', to: 'portal#media', as: 'document_media'
      get 'record/*id/parent', to: 'portal#parent', as: 'document_parent'
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

    get 'collections/art-history', to: redirect { |params, request|
      ["#{params[:locale]}/collections/art", request.query_string.presence].compact.join('?')
    }

    resources :collections, only: %i(show index) do
      get 'ugc', on: :member, path: 'contribute'
    end

    resources :federations, only: :show, constraints: { format: 'json' }
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

    scope 'explore' do
      resources :galleries, only: %i(show index), param: :slug do
        resources :gallery_images, only: :show, path: 'images', as: 'images', param: :position
      end

      constraints type: /people|periods|places|topics/, id: /\d+/ do
        get ':type/:id(-:slug)', as: 'entity', to: 'entities#show'
        get ':type/:id(-:slug)/promo', as: 'entity_promo', to: 'entities#promo'
      end
    end

    resources :blog_posts, only: %i(show index), param: :slug, path: 'blogs'

    get 'entities/suggest'

    get 'debug/exception', to: 'debug#exception'

    # Static pages
    get 'help/explore', to: redirect('%{locale}/help')
    get 'help/search', to: redirect('%{locale}/help')
    get 'help/results', to: redirect('%{locale}/help')

    get '*page', to: 'pages#show', as: 'static_page'

    mount Europeana::FeedbackButton::Engine, at: '/'
  end

  get 'csrf', to: 'application#csrf'

  put 'locale', to: 'locale#update'

  # CORS pre-flight requests
  match '*path', via: [:options],
                 to: ->(_) { [204, { 'Content-Type' => 'text/plain' }, []] }

  get '*path', to: 'locale#show'
end
