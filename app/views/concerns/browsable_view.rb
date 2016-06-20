##
# View methods for browsable collections
#
# Also used by the main search (from the homepage)
module BrowsableView
  extend ActiveSupport::Concern

  ##
  # Browse menu template data
  #
  # @return [Hash]
  def browse_menu
    return false if has_search_parameters?
    {
      menu_id: 'browse-menu',
      style_modifier: 'caret-right',
      items: browse_menu_items
    }
  end

  private

  ##
  # Items for the browse menu
  #
  # @return [Array<Hash>]
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

  ##
  # One item for the browse menu, within its submenu
  #
  # @param type [EDM::Type] EDM type to restrict browsing to
  # @return [Hash]
  def browse_menu_type_item(type)
    {
      text: type.label,
      url: search_action_path(q: "TYPE:#{type.id}", f: { 'MEDIA' => ['true'] }),
      icon: "icon-#{type.icon}"
    }
  end

  ##
  # Submenu of items within the browse menu
  #
  # @return [Array<Hash>]
  def browse_submenu_items
    items = EDM::Type.registry.map { |type| browse_menu_type_item(type) }
    items << { text: t('site.collections.data-types.all'), url: search_action_path(q: ''), icon: 'icon-ellipsis' }
  end
end
