# frozen_string_literal: true

module DateHelper
  def format_date(date, format = I18n.t('date.formats.default'))
    return date if format.nil? || (date.is_a?(String) && date !~ /^.+-/)
    Date.parse(date.to_s).strftime(format)
  rescue ArgumentError
    date
  end
end
