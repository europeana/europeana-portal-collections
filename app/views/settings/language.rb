module Settings
  class Language < ApplicationView
    def page_title
      'Europeana Collections - Language Settings'
    end

    def settings
      mustache[:settings] ||= begin
        {
          language: {
            form: {
              action: settings_language_path,
              method: 'PUT',
              form_authenticity_token: form_authenticity_token
            },
            title: t('site.settings.language.settings-label'),
            language_default: {
              title: t('site.settings.language.default'),
              group_id: t('site.settings.language.available'),
              items: [
                {
                  text: t('global.language-english'),
                  value: 'en',
                  selected: I18n.locale.to_s == 'en'
                },
                {
                  text: t('global.language-bulgarian'),
                  value: 'bg',
                  selected: I18n.locale.to_s == 'bg'
                },
                {
                  text: t('global.language-catalan'),
                  value: 'ca',
                  selected: I18n.locale.to_s == 'ca'
                },
                {
                  text: t('global.language-danish'),
                  value: 'da',
                  selected: I18n.locale.to_s == 'da'
                },
                {
                  text: t('global.language-dutch'),
                  value: 'nl',
                  selected: I18n.locale.to_s == 'nl'
                },
                {
                  text: t('global.language-finnish'),
                  value: 'fi',
                  selected: I18n.locale.to_s == 'fi'
                },
                {
                  text: t('global.language-french'),
                  value: 'fr',
                  selected: I18n.locale.to_s == 'fr'
                },
                {
                  text: t('global.language-german'),
                  value: 'de',
                  selected: I18n.locale.to_s == 'de'
                },
                {
                  text: t('global.language-greek'),
                  value: 'el',
                  selected: I18n.locale.to_s == 'el'
                },
                {
                  text: t('global.language-hungarian'),
                  value: 'hu',
                  selected: I18n.locale.to_s == 'hu'
                },
                {
                  text: t('global.language-lithuanian'),
                  value: 'lt',
                  selected: I18n.locale.to_s == 'lt'
                },
                {
                  text: t('global.language-polish'),
                  value: 'pl',
                  selected: I18n.locale.to_s == 'pl'
                },
                {
                  text: t('global.language-portuguese'),
                  value: 'pt',
                  selected: I18n.locale.to_s == 'pt'
                },
                {
                  text: t('global.language-romanian'),
                  value: 'ro',
                  selected: I18n.locale.to_s == 'ro'
                },
                {
                  text: t('global.language-russian'),
                  value: 'ru',
                  selected: I18n.locale.to_s == 'ru'
                },
                {
                  text: t('global.language-spanish'),
                  value: 'es',
                  selected: I18n.locale.to_s == 'es'
                },
                {
                  text: t('global.language-swedish'),
                  value: 'sv',
                  selected: I18n.locale.to_s == 'sv'
                }
              ]
            },
            language_itempages: {
              enabled: false,
              title: t('site.settings.language.auto-translate-page'),
              label: t('site.settings.language.auto-translate-page-short'),
              value: 'autotranslateitem',
              item_id: 'translate-item',
              is_checked: true,
              group_id: t('site.settings.language.available'),
              items: [
                {
                  text: t('global.language-dutch'),
                  value: 'nl'
                },
                {
                  text: t('global.language-russian'),
                  value: 'ru'
                },
                {
                  text: t('global.language-greek'),
                  value: 'el'
                }
              ]
            },
            language_translations: {
              enabled: false,
              title: t('site.settings.language.auto-translate-query'),
              limit: t('site.settings.language.auto-translate-limit', max_languages: 6),
              is_required: false,
              name: 'checkboxes[]',
              items: [
                {
                  text: t('global.language-french'),
                  value: 'fr',
                  item_id: 'fr'
                },
                {
                  text: t('global.language-german'),
                  value: 'de',
                  item_id: 'de'
                }
              ]
            }
          }
        }
      end
    end
  end
end
