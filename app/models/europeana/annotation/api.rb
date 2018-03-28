# frozen_string_literal: true

module Europeana
  class Annotation
    module API
      class << self
        def create_params(body:, user_token:)
          env_params.merge(body: body.to_json, userToken: user_token)
        end

        def search_params(**params)
          {
            query: '*:*',
            pageSize: 100
          }.merge(env_params).merge(params)
        end

        def fetch_params(provider:, id:)
          {
            provider: provider,
            id: id
          }.merge(env_params)
        end

        def delete_params(id:, user_token:)
          split_id = id.split('/')

          {
            userToken: user_token,
            provider: split_id[-2],
            id: split_id[-1]
          }.merge(env_params)
        end

        def env_params
          {
            wskey: Rails.application.config.x.europeana[:annotations].api_key || Europeana::API.key,
            api_url: Rails.application.config.x.europeana[:annotations].api_url || Europeana::API.url
          }
        end
      end
    end
  end
end
