# frozen_string_literal: true

class Europeana::Portal::DockerGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def generate_docker_config
    template 'docker-compose.yml', 'docker-compose.yml'

    %w(development test production).each_with_index do |env, index|
      configure_environment(env, index)
    end
  end

  protected

  def configure_environment(env, index)
    dotenv_file = ".env.#{env}"
    FileUtils.touch(dotenv_file)

    database_url = "postgres://postgres:#{postgres_password}@localhost:3002/europeana_collections_#{env}"

    redis_url = "redis://localhost:3003/#{index}"

    s3_bucket = "europeana-contribute-#{env}"
    minio_policy_path = "tmp/minio/.minio.sys/buckets/#{s3_bucket}/policy.json"
    template('minio-s3-policy.json', minio_policy_path)

    append_to_file(dotenv_file, <<~DOTENV
      
      # Injected by Europeana::Portal::DockerGenerator
      DATABASE_URL=#{database_url}
      REDIS_URL=#{redis_url}
      S3_REGION=eu-east-1
      S3_ACCESS_KEY_ID=#{minio_access_key}
      S3_SECRET_ACCESS_KEY=#{minio_secret_key}
      S3_ENDPOINT=http://localhost:3001
      S3_BUCKET=#{s3_bucket}
      S3_HOST=localhost
      S3_PATH_STYLE=1
    DOTENV
    )
  end

  def postgres_password
    @postgres_password ||= SecureRandom.hex(20)
  end

  def minio_access_key
    @minio_access_key ||= SecureRandom.hex(20)
  end

  def minio_secret_key
    @minio_secret_key ||= SecureRandom.hex(40)
  end
end
