class UrlValidator < ActiveModel::Validator
  def validate(record, attribute, value)
    value = false
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
