# frozen_string_literal: true

if defined?(Raven)
  Raven.configure do |config|
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
end
