##
# Pages with styleguide assets (CSS, JS, images)
module AssettedView
  extend ActiveSupport::Concern

  def css_files
    [
      {
        path: styleguide_url('/css_min/search/screen.css'),
        media: 'all'
      }
    ]
  end

  def js_vars
    page_name = (params[:controller] || '') + '/' + (params[:action] || '')
    [
      {
        name: 'pageName', value: page_name
      }
    ]
  end

  def js_files
    [
      {
        path: styleguide_url('/js_min/modules/require.js'),
        data_main: styleguide_url('/js_min/modules/main/templates/main-collections')
      }
    ]
  end
end
