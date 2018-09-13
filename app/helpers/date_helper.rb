# frozen_string_literal: true

module DateHelper
  def format_date(text, format = I18n.t('date.formats.default'))
    return text if format.nil? || (text !~ /^.+-/)
    Time.parse(text).strftime(format)
  rescue ArgumentError
    text
  end
end
