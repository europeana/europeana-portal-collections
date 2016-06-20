module BrowsableView
  extend ActiveSupport::Concern

  def browse_menu
    return false if has_search_parameters?
    {
      menu_id: 'browse-menu',
      style_modifier: 'caret-right',
      items: browse_menu_items
    }
  end

  private

  def browse_menu_items
    [
      {
        url: '#',
        text: t('site.search.browse'),
        text_mobile: t('site.search.or-browse'),
        submenu: {
          items: browse_submenu_items
        }
      }
    ]
  end

  def browse_menu_type_item(type)
    {
      text: type.label,
      url: search_action_path(q: "TYPE:#{type.id}", f: { 'MEDIA' => ['true'] }),
      icon: "icon-#{type.icon}"
    }
  end

  def browse_submenu_items
    items = EDM::Type.registry.map { |type| browse_menu_type_item(type) }
    items << { text: t('site.collections.data-types.all'), url: search_action_path(q: ''), icon: 'icon-ellipsis' }
  end
end
