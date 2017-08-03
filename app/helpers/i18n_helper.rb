# frozen_string_literal: true

module I18nHelper
  def language_map
    {
      bg: 'bulgarian',
      ca: 'catalan',
      da: 'danish',
      de: 'german',
      el: 'greek',
      en: 'english',
      es: 'spanish',
      et: 'estonian',
      fi: 'finnish',
      fr: 'french',
      hr: 'croatian',
      hu: 'hungarian',
      it: 'italian',
      lt: 'lithuanian',
      lv: 'latvian',
      mt: 'maltese',
      no: 'norwegian',
      nl: 'dutch',
      pl: 'polish',
      pt: 'portuguese',
      ro: 'romanian',
      ru: 'russian',
      sv: 'swedish'
    }
  end

  def language_options_for_select
    localised = language_map.map { |k, v| [t("global.language-#{v}", locale: k), k.to_s] }
    localised.sort_by!(&:first)
    options_for_select(localised, I18n.locale.to_s)
  end

  def date_eras_gregorian(date)
    return date unless date.is_a?(String)

    # Match on digits+ only, strip starting '0's and if date' length 1-3 then build "date' + CE"
    m = date.match(/^\d+$/)
    return build_date(m[0], '+') if m && strip_leading_zeroes(m[0]).length < 4

    # Match on '+' or '-' followed by date where date starts with digit followed by one or more digits or hyphens
    m = date.match(%r{^\s*(\+|\-)\s*(\d[\d\-\/]*)\s*$})
    return build_date(m[2], m[1]) if m

    # Otherwise do nothing.
    date.strip
  end

  private

  def build_date(year, prefix)
    year = strip_leading_zeroes(year)
    key = 'global.date.eras.gregorian.' + (prefix == '+' ? 'current' : 'before')
    default = year + ' ' + (prefix == '+' ? 'CE' : 'BCE')
    t(key, year: year, default: default)
  end

  def strip_leading_zeroes(s)
    s.strip.sub(/^0+/, '')
  end
end
