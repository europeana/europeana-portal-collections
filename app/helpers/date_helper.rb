# frozen_string_literal: true

module DateHelper
  def format_date(text, format)
    return text if format.nil? || (text !~ /^.+-/)
    Time.parse(text).strftime(format)
  rescue ArgumentError
    text
  end
end
