Blacklight::Routes.send(:include, BlacklightRoutes)

Rails.application.routes.draw do
  unless ENV['RAILS_RELATIVE_URL_ROOT'].blank?
    get '/', to: redirect(ENV['RAILS_RELATIVE_URL_ROOT'])
  end

  scope ENV['RAILS_RELATIVE_URL_ROOT'] || '/' do
    root to: 'home#index'
    get 'search', to: 'portal#index'

    blacklight_for :portal

    resources :channels, only: [:show, :index]
  end
end
