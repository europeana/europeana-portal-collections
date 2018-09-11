# frozen_string_literal: true

require 'dotenv'

module Europeana
  module Portal
    class DockerCommand < Thor::Group
      include Thor::Actions
      include Rails::Generators::Actions

      source_root File.expand_path('templates', __dir__)

      argument :rails_env, type: :string, default: 'development', desc: 'Rails env'

      class_option :europeana_api_key, type: :string, desc: 'Europeana API key'
      class_option :redis_db_index, type: :numeric, default: 0, desc: 'Redis database index'

      def copy_docker_compose
        template 'docker-compose.yml', 'docker-compose.yml'
      end

      def copy_docker_env
        template '.env.docker', '.env.docker'
      end

      def copy_minio_policy
        template 'minio-s3-policy.json', minio_policy_path
      end

      def copy_rails_env
        template '.env.rails', ".env.#{rails_env}"
      end

      protected

      def docker_env
        @docker_env ||= Dotenv.load('.env.docker')
      end

      def database_url
        @database_url ||= "postgres://postgres:#{postgres_password}@localhost:#{postgres_port}/europeana_portal_#{rails_env}"
      end

      def redis_url
        @redis_url ||= "redis://localhost:#{redis_port}/#{options[:redis_db_index]}"
      end

      def redis_port
        '3013'
      end

      def s3_bucket
        @s3_bucket ||= "europeana-portal-#{rails_env}"
      end

      def minio_policy_path
        @minio_policy_path ||= "tmp/minio/.minio.sys/buckets/#{s3_bucket}/policy.json"
      end

      def postgres_password
        @postgres_password ||= docker_env['POSTGRES_PASSWORD'] || SecureRandom.hex(20)
      end

      def postgres_port
        '3012'
      end

      def minio_access_key
        @minio_access_key ||= docker_env['MINIO_ACCESS_KEY'] || SecureRandom.hex(20)
      end

      def minio_secret_key
        @minio_secret_key ||= docker_env['MINIO_SECRET_KEY'] || SecureRandom.hex(40)
      end

      def minio_port
        '3011'
      end

      def secret_key_base
        @secret_key_base ||= SecureRandom.hex(64)
      end

      def europeana_api_key
        @europeana_api_key ||= options[:europeana_api_key] || ask('Europeana API key:')
      end
    end
  end
end
