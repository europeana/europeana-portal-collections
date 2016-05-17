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
              items: language_default_items
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

    protected

    def language_item(k, v)
      {
        text: t("global.language-#{v}"),
        value: k.to_s,
        selected: I18n.locale.to_sym == k
      }
    end

    def language_default_items
      languages = enabled_ui_language_keys.dup
      [language_item(:en, languages.delete(:en))] +
        languages.sort_by { |_k, v| v }.map { |k, v| language_item(k, v) }
    end
  end
end
