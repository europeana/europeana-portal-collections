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

  def js_vars
    page_name = (params[:controller] || '') + '/' + (params[:action] || '')
    if params[:new_item_page].to_s == 'true'
      page_name = page_name.sub('portal/show', 'portal/show-new')
    end
    [
      {
        name: 'pageName', value: page_name
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
end
