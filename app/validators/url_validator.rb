class UrlValidator < ActiveModel::EachValidator
  # @todo move error message into locales
  def validate_each(record, attribute, value)
    valid = false
    begin
      uri = URI(value)
      valid = uri.is_a?(URI::HTTP) || (options[:allow_local] && uri.scheme.nil? && uri.host.nil?)
    rescue URI::InvalidURIError
      valid = false
    end
    unless valid
      record.errors[attribute] << (options[:message] || "is not a URL")
    end
  end
end
