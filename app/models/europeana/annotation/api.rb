# frozen_string_literal: true

module Europeana
  class Annotation
    module API
      class << self
        def search_params(**params)
          {
            query: '*:*',
            pageSize: 100
          }.merge(env_params).merge(params)
        end

        def delete_params(id)
          split_id = id.split('/')

          {
            provider: split_id[-2],
            id: split_id[-1],
          }.merge(env_params_with_token)
        end

        def fetch_params(provider, id)
          {
            provider: provider,
            id: id
          }.merge(env_params)
        end

        def create_params(body)
          env_params_with_token.merge(body: body.to_json)
        end

        def env_params
          {
            wskey: Rails.application.config.x.europeana[:annotations].api_key || Europeana::API.key,
            api_url: Rails.application.config.x.europeana[:annotations].api_url || Europeana::API.url,
          }
        end

        def env_params_with_token
          {
            userToken: Rails.application.config.x.europeana[:annotations].api_user_token_gallery || ''
          }.merge(env_params)
        end
      end
    end
  end
end
