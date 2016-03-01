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
      # et: 'estonian',
      fi: 'finnish',
      fr: 'french',
      hr: 'croatian',
      hu: 'hungarian',
      it: 'italian',
      lt: 'lithuanian',
      lv: 'latvian',
      nl: 'dutch',
      pl: 'polish',
      pt: 'portuguese',
      ro: 'romanian',
      ru: 'russian',
      sv: 'swedish'
    }
  end

  def language_options_for_select
    localised = language_map.map { |k, v| [t("global.language-#{v}"), k.to_s] }
    localised.sort_by! { |v| v.first }
    options_for_select(localised, I18n.locale.to_s)
  end
end
