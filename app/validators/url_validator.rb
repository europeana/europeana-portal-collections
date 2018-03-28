# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator
  # @todo move error message into locales
  def validate_each(record, attribute, value)
    unless valid_url?(value)
      record.errors[attribute] << (options[:message] || 'is not a URL')
    end
  end

  def valid_url?(value)
    uri = URI(value)
    uri.is_a?(URI::HTTP) || (options[:allow_local] && uri.scheme.nil? && uri.host.nil?)
  rescue URI::InvalidURIError
    false
  end
end
