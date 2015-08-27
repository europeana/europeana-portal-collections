class UrlValidator < ActiveModel::EachValidator
  # @todo move error message into locales
  def validate_each(record, attribute, value)
    valid = false
    begin
      valid = URI(value).is_a?(URI::HTTP)
    rescue URI::InvalidURIError
      valid = false
    end
    unless valid
      record.errors[attribute] << (options[:message] || "is not a URL")
    end
  end
end
