module MustacheHelper
  def head_meta
    [
      #{'name':'X-UA-Compatible',    content: 'IE=edge' },
      #{'name':'viewport',           content: 'width=device-width,initial-scale=1.0' },
      { meta_name: 'HandheldFriendly',   content: 'True' },
      { httpequiv: 'Content-Type',       content: 'text/html; charset=utf-8' },
      { meta_name: 'csrf-param',         content: 'authenticity_token' },
      { meta_name: 'csrf-token',         content: form_authenticity_token }
    ]
  end

  def page_title
    if @response.nil?
      'Europeana Channels'
    elsif @response['action'].to_s == 'search.json'
      'Europeana Search' + search_page_title
    elsif params[:action].to_s == 'show'
      if @document.is_a?(Blacklight::Document)
        rec = @document.get(:title) || ''
        'Europeana Record' + (rec.present? ? ': ' + rec : rec)
      end
    end
  end

  def form_action_search
    request.protocol + request.host_with_port + '/'
  end

  def head_links
    [
      { rel: 'search',         type: 'application/opensearchdescription+xml', href: request.host_with_port + '/catalog/opensearch.xml', title: 'Blacklight' },
      { rel: 'shortcut icon',  type: 'image/x-icon',                          href: asset_path('favicon.ico') },
      { rel: 'stylesheet',     href: asset_path('blacklight.css'),            media: 'all' },
      { rel: 'stylesheet',     href: asset_path('europeana.css'),             media: 'all' },
      { rel: 'stylesheet',     href: asset_path('application.css'),           media: 'all' }
    ]
  end

  # model for the search form
  def input_search
    {
      title: 'Search',
      input_name: 'q[]',
      empty: params[:q].blank?,
      input_values: input_search_values(params[:q]),
      placeholder: 'Add a search term'
    }
  end

  def image_root
    'http://develop.styleguide.eanadev.org/images/'
  end

  def js_files
    [
      { path: asset_path('jquery.js') },
      { path: 'http://develop.styleguide.eanadev.org/js/dist/application.js' },
      #{ path: 'http://localhost/Europeana-Patternlab/public/js/dist/application.js' },
      # Blacklight dependencies
      #{ path: asset_path('turbolinks.js') },
      #{ path: asset_path('blacklight/core.js') },
      #{ path: asset_path('blacklight/autofocus.js') },
      #{ path: asset_path('blacklight/checkbox_submit.js') },
      #{ path: asset_path('blacklight/bookmark_toggle.js') },
      #{ path: asset_path('blacklight/ajax_modal.js') },
      { path: asset_path('blacklight/search_context.js') }
      #{ path: asset_path('blacklight/collapsable.js') },
      #{ path: asset_path('bootstrap/transition.js') },
      #{ path: asset_path('bootstrap/collapse.js') },
      #{ path: asset_path('bootstrap/dropdown.js') },
      #{ path: asset_path('bootstrap/alert.js') },
      #{ path: asset_path('bootstrap/modal.js') },
      #{ path: asset_path('blacklight/blacklight.js') }
    ]
  end

  def menus
    {
      actions: {
        button_title: 'Actions',
        menu_id: 'dropdown-result-actions',
        menu_title: 'Save to:',
        items: [
          {
            url: 'http://europeana.eu',
            text: 'First Item'
          },
          {
            url: 'http://europeana.eu',
            text: 'Another Label'
          },
          {
            url: 'http://europeana.eu',
            text: 'Label here'
          },
          {
            url: 'http://europeana.eu',
            text: 'Fourth Item'
          },
          {
            divider: true
          },
          {
            url: 'http://europeana.eu',
            text: 'Another Label',
            calltoaction: true
          },
          {
            divider: true
          },
          {
            url: 'http://europeana.eu',
            text: 'Another Label',
            calltoaction: true
          }
        ]
      },
      sort: {
        button_title: 'Relevance',
        menu_id: 'dropdown-result-sort',
        menu_title: 'Sort by:',
        items: [
          {
            text: 'Date',
            url: 'http://europeana.eu'
          },
          {
            text: 'Alphabetical',
            url: 'http://europeana.eu'
          },
          {
            text: 'Relevance',
            url: 'http://europeana.eu'
          },
          {
            divider: true
          },
          {
            url: 'http://europeana.eu',
            text: 'Another Label',
            calltoaction: true
          },
          {
            divider: true
          },
          {
            text: 'Advanced Search',
            url: 'http://europeana.eu',
            calltoaction: true
          }
        ]
      }
    }
  end

  def channels_nav_links
    available_channels.collect do |c|
      {
        url: channel_path(c),
        text: c
      }
    end
  end

  private

  def search_page_title
    if params[:q].nil?
      ''
    else
      ': ' + safe_join([params[:q]].flatten, ', ')
    end
  end

  # @param qs [Array] q params
  # @return [Array<Hash>]
  def input_search_values(qs)
    return [] if qs.nil?
    qs.reject(&:blank?).collect do |q|
      {
        value: q,
        remove: search_action_path(remove_q_param(q, params))
      }
    end
  end
end
