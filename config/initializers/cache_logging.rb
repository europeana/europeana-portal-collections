# frozen_string_literal: true

ActiveSupport::Cache::Store.logger = Rails.logger if ENV['LOG_CACHING']
