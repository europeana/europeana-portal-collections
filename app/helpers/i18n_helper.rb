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
    m = date.match(/^\s*(\+|\-)\s*0*(.*)$/)
    if m
      year = m[2].strip
      key = 'global.date.eras.gregorian.' + (m[1] == '+' ? 'current' : 'before')
      default = m[2] + ' ' + (m[1] == '+' ? 'CE' : 'BCE')
      t(key, year: year, default: default)
    else
      date.strip
    end
  end
end
