module BrowsableView
  extend ActiveSupport::Concern

  def browse_menu
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
          items: EDM::Type.registry.map { |type| browse_menu_type_item(type) }
        }
      }
    ]
  end

  def browse_menu_type_item(type)
    {
      text: type.label,
      url: search_action_path(q: "TYPE:#{type.id}"),
      icon: "icon-#{type.icon}"
    }
  end
end
