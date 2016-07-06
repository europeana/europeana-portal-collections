##
# Methods for views that need to filter by collection
module CollectionFilterableView
  extend ActiveSupport::Concern

  def collection_filter_options
    ops = displayable_collections.map do |collection|
      {
        value: collection.key,
        label: collection.landing_page.title,
        selected: params['theme'] == collection.key
      }
    end
    {
      options: ops.unshift({
        value: '*',
        label: t('global.actions.filter-all')
      })
    }
  end
end
