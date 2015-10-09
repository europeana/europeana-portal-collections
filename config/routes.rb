Blacklight::Routes.send(:include, BlacklightRoutes)

Rails.application.routes.draw do
  unless Rails.application.config.relative_url_root.blank?
    get '/', to: redirect(Rails.application.config.relative_url_root)
  end

  scope Rails.application.config.relative_url_root || '/' do
    root to: 'home#index'
    get 'search', to: 'portal#index'

    constraints id: %r{[^/]+/[^/]+} do
      get 'record/*id/hierarchy', to: 'portal#hierarchy', as: 'document_hierarchy'
      get 'record/*id/media', to: 'portal#media', as: 'document_media'
      get 'record/*id/similar', to: 'portal#similar', as: 'document_similar'
    end
    blacklight_for :portal

    resources :channels, only: [:show, :index]

    get 'browse/colours', to: 'browse#colours'
    get 'browse/newcontent', to: 'browse#new_content'

    get 'settings/language', to: 'settings#language'
    put 'settings/language', to: 'settings#update_language'

    # Static pages
    get ':page', to: 'portal#static', constraints: { page: %r{(about|channels/music/about)} }
  end
end
