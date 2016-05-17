module I18nHelper
  ##
  # Locales enabled in the site UI
  #
  # This determines the languages presented as options on the language settings
  # page, /settings/language
  #
  # @return [Array<Symbol>]
  def enabled_ui_locales
    %i(bg ca da de el en es fi fr hr hu it lt lv nl pl pt ro ru sv)
  end

  ##
  # Mapping of locale codes to keys used in locale translations
  #
  # @return [HashWithIndifferentAccess]
  def locale_language_keys
    HashWithIndifferentAccess.new(
      eu: 'basque',
      bg: 'bulgarian',
      ca: 'catalan',
      hr: 'croatian',
      cs: 'czech',
      da: 'danish',
      nl: 'dutch',
      en: 'english',
      et: 'estonian',
      fi: 'finnish',
      fr: 'french',
      ga: 'gaelic',
      de: 'german',
      el: 'greek',
      hu: 'hungarian',
      is: 'icelandic',
      it: 'italian',
      lv: 'latvian',
      lt: 'lithuanian',
      mt: 'maltese',
      no: 'norwegian',
      pl: 'polish',
      pt: 'portuguese',
      ro: 'romanian',
      ru: 'russian',
      sk: 'slovakian',
      sl: 'slovenian',
      es: 'spanish',
      sv: 'swedish',
      uk: 'ukranian'
    )
  end

  def enabled_ui_language_keys
    locale_language_keys.slice(*enabled_ui_locales)
  end

  ##
  # Option tags for use in a select field to present a choice of UI languages
  def ui_language_options_for_select
    localised = enabled_ui_language_keys.map { |k, v| [t("global.language-#{v}"), k.to_s] }
    localised.sort_by!(&:first)
    options_for_select(localised, I18n.locale.to_s)
  end
end
