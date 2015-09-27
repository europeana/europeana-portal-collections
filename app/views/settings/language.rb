module Settings
  class Language < ApplicationView
    def page_title
      'Europeana Collections - Language Settings'
    end

    def settings
      {
        language: {
          form: {
            action: root_url + '/settings/language',
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
                text: t('global.language-dutch'),
                value: 'nl',
                selected: I18n.locale.to_s == 'nl'
              }
            ]
          },
          language_itempages: {

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
                text:  t('global.language-greek'),
                value: 'el'
              }
            ]
          },
          language_options: {
            title: t('site.settings.language.auto-translate-query'),
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
