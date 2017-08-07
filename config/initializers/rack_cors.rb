# frozen_string_literal: true

if ENV['CORS_ORIGINS']
  Rails.application.configure do
    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        origins ENV['CORS_ORIGINS'].split(' ')
        resource '*',
          headers: :any,
          methods: [:get, :post, :delete, :put, :patch, :options, :head],
          max_age: 0
      end
    end
  end
end
