# frozen_string_literal: true

##
# Pages with styleguide assets (CSS, JS, images)
module AssettedView
  extend ActiveSupport::Concern

  def css_files
    [
      {
        path: styleguide_url('/css/search/screen.css'),
        media: 'all'
      }
    ]
  end

  def js_files
    [
      {
        path: styleguide_url('/js/modules/require.js'),
        data_main: styleguide_url('/js/modules/main/templates/main-collections')
      }
    ]
  end

  def js_application_requirements
    [
      asset_path('application.js'),
      asset_path("/javascripts/i18n/#{I18n.locale}.js")
    ]
  end
end
